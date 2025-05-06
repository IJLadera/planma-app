from celery import shared_task
from django.utils import timezone
from datetime import timedelta, datetime
from .models import UserPref, CustomTask, CustomClassSchedule, CustomActivity, CustomEvents, Goals
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync
import logging
from django.utils.timezone import make_aware
from typing import List
from django.db.models import Q

logger = logging.getLogger(__name__)

@shared_task
def send_reminders():
    # Get all users who have preferences set
    user_prefs: List[UserPref] = UserPref.objects.all()
    
    # First send all sleep reminders
    send_sleep_reminders()
    
    for user_pref in user_prefs:
        user_id = user_pref.student_id.student_id
        
        # 1. Process class reminders
        send_class_reminders(user_id, user_pref)
        
        # 2. Process task reminders
        send_task_reminders(user_id, user_pref)
        
        # 3. Process activity reminders
        send_activity_reminders(user_id, user_pref=user_pref)
        
        # 4. Process event reminders
        send_event_reminders(user_id, user_pref)
        
        # 5. Process goal reminders
        send_goal_reminders(user_id, user_pref)
        
        
@shared_task
def send_sleep_reminders():
    """
    Send sleep reminders to users based on their preferred sleep times.
    This function checks each user's usual sleep time and sends a reminder
    at the appropriate time before they should go to sleep.
    """
    # Get all users who have preferences set
    user_prefs = UserPref.objects.all()
    
    current_time = make_aware(datetime.now())
    current_date = current_time.date()
    
    for user_pref in user_prefs:
        user_id = user_pref.student_id.student_id
        
        # Convert sleep time to a datetime for today
        sleep_datetime = datetime.combine(current_date, user_pref.usual_sleep_time)
        sleep_datetime = make_aware(sleep_datetime)
        
        # Calculate when to send the reminder (using the user's reminder offset)
        reminder_time = sleep_datetime - user_pref.reminder_offset_time
        
        # Define time window for sending reminders (avoid duplicate reminders)
        time_window = timedelta(minutes=2)
        
        # Check if it's time to send the reminder
        if current_time >= reminder_time and current_time <= reminder_time + time_window:
            # Calculate hours of sleep they will get if they sleep now
            wake_datetime = datetime.combine(current_date + timedelta(days=1), user_pref.usual_wake_time)
            wake_datetime = make_aware(wake_datetime)
            
            # Handle case where wake time might be on the same day
            if wake_datetime < sleep_datetime:
                wake_datetime = datetime.combine(current_date, user_pref.usual_wake_time)
                wake_datetime = make_aware(wake_datetime)
            
            sleep_duration = wake_datetime - sleep_datetime
            sleep_hours = round(sleep_duration.total_seconds() / 3600, 1)
            
            # Send the reminder to WebSocket for this user
            channel_layer = get_channel_layer()
            async_to_sync(channel_layer.group_send)(
                f"user_{user_id}",
                {
                    'type': 'send_reminder',
                    'reminder': {
                        'title': "Sleep Reminder",
                        'scheduled_sleep_time': user_pref.usual_sleep_time.strftime("%H:%M"),
                        'scheduled_wake_time': user_pref.usual_wake_time.strftime("%H:%M"),
                        'sleep_hours': sleep_hours,
                        'reminder': f"Time to prepare for sleep! You usually go to bed at {user_pref.usual_sleep_time.strftime('%H:%M')} for {sleep_hours} hours of sleep.",
                        'reminder_type': 'sleep_reminder',
                    }
                }
            )
            
            # You might want to add a field to track this
            user_pref.last_sleep_reminder_date = current_date
            user_pref.save()
 
        
@shared_task
def send_class_reminders(user_id: str, user_pref: UserPref):
    
    # Get current day of week
    current_day = make_aware(datetime.now()).strftime('%A') # e.g., 'Monday'
    
    current_date = make_aware(datetime.now()).date()

    # Get all class schedules for the user on the current day
    class_schedules = CustomClassSchedule.objects.filter(
        student_id__student_id=user_id,
        day_of_week=current_day
    ).filter(
        Q(last_reminder_date__isnull=True) | ~Q(last_reminder_date=current_date)
    )
    
    current_time = make_aware(datetime.now())
    
    # Loop through each class and check if the reminder time is near
    for class_schedule in class_schedules:
        # Combine current date with class start time
        class_datetime = datetime.combine(current_date, class_schedule.scheduled_start_time)
        class_datetime = make_aware(class_datetime)
        
        # Calculate when to send the reminder
        reminder_time = class_datetime - user_pref.reminder_offset_time
        
        # Check if it's time to send the reminder
        # We need to track if a reminder has been sent, so let's add this field to the model
        # For now, we'll check based on time proximity
        time_window = timedelta(minutes=2) # Only send reminders in a 2-minute window
        
        if (current_time >= reminder_time and current_time <= reminder_time + time_window):
            
            # Send the reminder to WebSocket for this user
            channel_layer = get_channel_layer()
            async_to_sync(channel_layer.group_send)(
                f"user_{user_id}",
                {
                    'type': 'send_reminder', # Reuse the same handler
                    'reminder': {
                        'class_id': class_schedule.classsched_id,
                        'title': f"Class Reminder: {class_schedule.subject.subject_title}",
                        'scheduled_start_time': class_schedule.scheduled_start_time.strftime("%H:%M"),
                        'room': class_schedule.room,
                        'reminder': f"Your class starts in {user_pref.reminder_offset_time}",
                        'reminder_type': 'class_reminder',
                    }
                    
                }
            )
            
            # Mark reminder as sent for today
            class_schedule.last_reminder_date = current_date
            class_schedule.save()
            
@shared_task
def send_activity_reminders(user_id: str, user_pref: UserPref):
    
    # Get all activities for the user
    activities = CustomActivity.objects.filter(student_id__student_id=user_id)
    
    # Loop through each activity and check if the reminder time is near
    for activity in activities:
        scheduled_datetime = datetime.combine(activity.scheduled_date, activity.scheduled_start_time)
        
        # Make the scheduled datetime timezone-aware
        scheduled_datetime = make_aware(scheduled_datetime)
        reminder_time = scheduled_datetime - user_pref.reminder_offset_time
        
        # Check if it's time to send the reminder
        current_time = make_aware(datetime.now())
        if current_time >= reminder_time and not activity.reminder_sent:
            # Send the reminder to WebSocket for this user
            channel_layer = get_channel_layer()
            async_to_sync(channel_layer.group_send)(
                f"user_{user_id}", # User's WebSocket group
                {
                    'type': 'send_reminder',
                    'reminder': {
                        'task_id': activity.activity_id,
                        'title': f"Reminder: {activity.student_id.student_id}'s Task",
                        'scheduled_start_time': activity.scheduled_start_time.strftime("%H:%M"),
                        'reminder': f"Reminder {user_pref.reminder_offset_time} before activity",
                        'reminder_type': "activity_reminder"
                    }
                    
                }
            )
            
 
@ shared_task
def send_goal_reminders(user_id: str, user_pref: UserPref):
    """
    Send reminders for goals that need attention based on user preferences.
    This function checks if users are making progress toward their goals and send reminders accordingly.
    """
    
    # Get all goals for the user
    goals = Goals.objects.filter(student_id__student_id=user_id)
    
    current_time = make_aware(datetime.now())
    current_date = current_time.date()
    
    # Loop through each goal and check if a reminder is neede
    for goal in goals:
        # Get the appropriate reminder schedule based on timeframe
        if goal.timeframe == 'Daily':
            # For daily goals, we'll remind at a fixed time before sleep
            reminder_datetime = datetime.combine(current_date, user_pref.usual_sleep_time) 
            reminder_datetime = make_aware(reminder_datetime) - timedelta(hours=2)
        elif goal.timeframe == 'Weekly':
            # For weekly goals, remind on Friday evening
            days_until_friday = (4 - current_time.weekday()) % 7  # Friday is 4
            reminder_date = current_date + timedelta(days=days_until_friday)
            reminder_datetime = datetime.combine(reminder_date, user_pref.usual_sleep_time)
            reminder_datetime = make_aware(reminder_datetime) - timedelta(hours=2)
        elif goal.timeframe == 'Monthly':
            # For monthly goals, remind on the 25th of each month
            if current_date.day == 25:
                reminder_datetime = datetime.combine(current_date, user_pref.usual_sleep_time)
                reminder_datetime = make_aware(reminder_datetime) - timedelta(hours=2)
            else:
                continue  # Skip if not the 25th
        
        # Calculate the reminder time with the user's offset preference
        reminder_time = reminder_datetime - user_pref.reminder_offset_time
        
        # Define time window for sending reminders (to avoid duplicate reminders)
        time_window = timedelta(minutes=2)
        
        # Check if we should send a reminder now
        if current_time >= reminder_time and current_time <= reminder_time + time_window:
            # Add a field to track if reminder was sent today
            # For simplicity, let's assume you'll add this field to the Goals model
            
            # Create a property on the goal to determine progress status
            progress_status = "Need attention"  # This would ideally be calculated based on actual progress data
            
            # Send the reminder to WebSocket for this user
            channel_layer = get_channel_layer()
            async_to_sync(channel_layer.group_send)(
                f"user_{user_id}",
                {
                    'type': 'send_reminder',
                    'reminder': {
                        'goal_id': goal.goal_id,
                        'title': f"Goal Reminder: {goal.goal_name}",
                        'timeframe': goal.timeframe,
                        'target_hours': goal.target_hours,
                        'progress_status': progress_status,
                        'reminder': f"Don't forget your {goal.timeframe.lower()} goal: {goal.goal_name}",
                        'reminder_type': 'goal_reminder',
                    }
                }
            )
            
            # For tracking purposes
            goal.last_reminder_date = current_date
            goal.save()

        
@shared_task
def send_event_reminders(user_id: str, user_pref: UserPref):
        
    # Get all events for the user
    events = CustomEvents.objects.filter(student_id__student_id=user_id)
    
    # Loop through each event and check if the reminder time is near
    for event in events:
        scheduled_datetime = datetime.combine(event.scheduled_date, event.scheduled_start_time)
        
        # Make the scheduled datetime timezone-aware
        scheduled_datetime = make_aware(scheduled_datetime)
        reminder_time = scheduled_datetime - user_pref.reminder_offset_time
        
        # Check if it's time to send the reminder
        current_time = make_aware(datetime.now())
        
        if current_time >= reminder_time and not event.reminder_sent:
            # Send the reminder to WebSocket for this user
            channel_layer = get_channel_layer()
            async_to_sync(channel_layer.group_send)(
                f"user_{user_id}", # User's WebSocket group
                {
                    'type': 'send_reminder',
                    'reminder': {
                        'task_id': event.event_id,
                        'title': f"Reminder: {event.student_id.student_id}'s Task",
                        'scheduled_start_time': event.scheduled_start_time.strftime("%H:%M"),
                        'reminder': f"Reminder {user_pref.reminder_offset_time} before event",
                        'reminder_type': "event_reminder"
                    }
                    
                }
            )
            
            # Mark reminder as sent
            event.reminder_sent = True
            event.save()

        
@shared_task
def send_task_reminders(user_id: str, user_pref: UserPref):
            
    # Get all tasks for the user
    tasks = CustomTask.objects.filter(student_id__student_id=user_id)
    
    print(user_pref.student_id.student_id)

    # Loop through each task and check if the reminder time is near
    for task in tasks:
        scheduled_datetime = datetime.combine(task.scheduled_date, task.scheduled_start_time)
        
        # Make the scheduled datetime timezone-aware
        scheduled_datetime = make_aware(scheduled_datetime)
        reminder_time = scheduled_datetime - user_pref.reminder_offset_time

        # Check if it's time to send the reminder
        current_time = make_aware(datetime.now())
        
        if current_time >= reminder_time and not task.reminder_sent:
            # Send the reminder to WebSocket for this user
            channel_layer = get_channel_layer()
            async_to_sync(channel_layer.group_send)(
                f"user_{user_id}", # User's WebSocket group
                {
                    'type': 'send_reminder',
                    'reminder': {
                        'task_id': task.task_id,
                        'title': f"Reminder: {task.student_id.student_id}'s Task",
                        'scheduled_start_time': task.scheduled_start_time.strftime("%H:%M"),
                        'reminder': f"Reminder {user_pref.reminder_offset_time} before task",
                        'reminder_type': "task_reminder"
                    }
                    
                }
            )
            
            # Mark reminder as sent
            task.reminder_sent = True
            task.save()
