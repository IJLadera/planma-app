from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync
from django.utils import timezone
from datetime import timedelta
from celery import shared_task
from .models import (
    CustomEvents, UserPref, CustomTask, CustomClassSchedule, CustomActivity,
    Goals, GoalSchedule, CustomUser
)

def send_sleep_reminders():
    """Check for sleep reminders and send notifications"""

    now = timezone.now()
    today = now.date()

    # Get all user preferences
    user_prefs = UserPref.objects.filter(
        student_id__is_active=True
    ).select_related('student_id')

    channel_layer = get_channel_layer()

    for pref in user_prefs:
        # Skip if reminder was already sent today
        if pref.last_sleep_reminder_date == today:
            continue

        # Create datetime objects for sleep and wake times today
        sleep_time = timezone.make_aware(
            timezone.datetime.combine(today, pref.usual_sleep_time)
        )

        # Calculate when reminder should be sent (30 minutes before sleep time)
        reminder_offset = pref.reminder_offset_time or timedelta(minutes=30)
        reminder_time = sleep_time - reminder_offset

        # If it's time to send the reminder
        if now >= reminder_time and now <= sleep_time:
            # Format the sleep time nicely
            formatted_sleep_time = sleep_time.strftime('%I:%M %p')

            # Send to user's channel group
            async_to_sync(channel_layer.group_send)(
                f'user_{pref.student_id.student_id}',
                {
                    'type': 'reminder_notification',
                    'reminder_type': 'sleep',
                    'reminder': f"Time to prepare for bed - you should be asleep by {formatted_sleep_time}"
                }
            )

            # Update last reminder date
            pref.last_sleep_reminder_date = today
            pref.save()

def send_task_reminders():
    """Check for task reminders and send notifications"""
    now = timezone.now()

    # Get tasks that are due soon but haven't had reminders sent
    upcoming_tasks = CustomTask.objects.filter(
        reminder_sent=False,
        status__in=['Pending', 'In Progress'],
        deadline__gt=now,  # Hasn't passed yet
    ).select_related('student_id', 'subject_id')

    channel_layer = get_channel_layer()

    print('Channel Check')
    print(now)
    for task in upcoming_tasks:
        # Get user preferences for reminder timing
        try:
            user_pref = UserPref.objects.get(student_id=task.student_id)
            reminder_offset = user_pref.reminder_offset_time
        except UserPref.DoesNotExist:
            # Default to 30 minutes if no preference set
            reminder_offset = timedelta(minutes=30)

        # Calculate when reminder should be sent
        reminder_time = task.deadline - reminder_offset

        print('Time Check')
        print(now) 
        print(reminder_time) 
        # If it's time to send the reminder
        if now >= reminder_time:
            # Prepare reminder data
            subject_name = task.subject_id.subject_title if task.subject_id else "No subject"
            time_remaining = task.deadline - now
            hours_remaining = round(time_remaining.total_seconds() / 3600, 1)

            reminder_data = {
                'id': task.task_id,
                'name': task.task_name,
                'description': task.task_desc,
                'deadline': task.deadline.isoformat(),
                'subject': subject_name,
                'hours_remaining': hours_remaining
            }

            # Send to user's channel group
            async_to_sync(channel_layer.group_send)(
                f'user_{task.student_id.student_id}',
                {
                    'type': 'reminder_notification',
                    'reminder_type': 'task',
                    'reminder': reminder_data
                }
            )

            # Mark as sent
            task.reminder_sent = True
            task.save()

def send_event_reminders():
    """Check for event reminders and send notifications"""
    now = timezone.now()
    today = now.date()

    # Get events scheduled for today that haven't had reminders sent
    upcoming_events = CustomEvents.objects.filter(
        reminder_sent=False,
        scheduled_date__gte=today,  # Today or in the future
    ).select_related('student_id')

    channel_layer = get_channel_layer()

    for event in upcoming_events:
        # Get user preferences for reminder timing
        try:
            user_pref = UserPref.objects.get(student_id=event.student_id)
            reminder_offset = user_pref.reminder_offset_time
        except UserPref.DoesNotExist:
            # Default to 30 minutes if no preference set
            reminder_offset = timedelta(minutes=30)
        
        # Create a datetime object for the event
        event_datetime = timezone.make_aware(
            timezone.datetime.combine(event.scheduled_date, event.scheduled_start_time)
        )
        
        # Calculate when reminder should be sent
        reminder_time = event_datetime - reminder_offset
        
        # If it's time to send the reminder (and event hasn't started yet)
        if now >= reminder_time and now < event_datetime:
            # Prepare reminder data
            reminder_data = {
                'id': event.event_id,
                'name': event.event_name,
                'description': event.event_desc,
                'location': event.location,
                'scheduled_date': event.scheduled_date.isoformat(),
                'start_time': event.scheduled_start_time.isoformat(),
                'end_time': event.scheduled_end_time.isoformat(),
                'event_type': event.event_type
            }
            
            # Send to user's channel group
            async_to_sync(channel_layer.group_send)(
                f'user_{event.student_id.student_id}',
                {
                    'type': 'reminder_notification',
                    'reminder_type': 'event',
                    'reminder': reminder_data
                }
            )
            
            # Mark as sent
            event.reminder_sent = True
            event.save()
        
def send_class_reminders():
    """Check for class reminders and send notifications"""
    now = timezone.now()
    today = now.date()
    current_day = today.strftime("%A")  # Get the day name (e.g., "Monday")
    
    # Get class schedules for today that haven't had reminders sent today
    class_schedules = CustomClassSchedule.objects.filter(
        day_of_week=current_day,
        last_reminder_date__lt=today  # No reminder sent today
    ).select_related('student_id', 'subject')
    
    channel_layer = get_channel_layer()
    
    for class_schedule in class_schedules:
        # Get user preferences for reminder timing
        try:
            user_pref = UserPref.objects.get(student_id=class_schedule.student_id)
            reminder_offset = user_pref.reminder_offset_time
        except UserPref.DoesNotExist:
            # Default to 30 minutes if no preference set
            reminder_offset = timedelta(minutes=30)
        
        # Create a datetime object for the class
        class_datetime = timezone.make_aware(
            timezone.datetime.combine(today, class_schedule.scheduled_start_time)
        )
        
        # Calculate when reminder should be sent
        reminder_time = class_datetime - reminder_offset
        
        # If it's time to send the reminder (and class hasn't started yet)
        if now >= reminder_time and now < class_datetime:
            # Prepare reminder data
            reminder_data = {
                'id': class_schedule.classsched_id,
                'subject_code': class_schedule.subject.subject_code,
                'subject_title': class_schedule.subject.subject_title,
                'room': class_schedule.room,
                'start_time': class_schedule.scheduled_start_time.isoformat(),
                'end_time': class_schedule.scheduled_end_time.isoformat()
            }
            
            # Send to user's channel group
            async_to_sync(channel_layer.group_send)(
                f'user_{class_schedule.student_id.student_id}',
                {
                    'type': 'reminder_notification',
                    'reminder_type': 'class',
                    'reminder': reminder_data
                }
            )
            
            # Update last reminder date
            class_schedule.last_reminder_date = today
            class_schedule.save()

def send_activity_reminders():
    """Check for activity reminders and send notifications"""
    now = timezone.now()
    today = now.date()
    
    # Get activities scheduled for today that haven't had reminders sent
    upcoming_activities = CustomActivity.objects.filter(
        reminder_sent=False,
        status__in=['Pending', 'In Progress'],
        scheduled_date__gte=today,  # Today or in the future
    ).select_related('student_id')
    
    channel_layer = get_channel_layer()
    
    for activity in upcoming_activities:
        # Get user preferences for reminder timing
        try:
            user_pref = UserPref.objects.get(student_id=activity.student_id)
            reminder_offset = user_pref.reminder_offset_time
        except UserPref.DoesNotExist:
            # Default to 30 minutes if no preference set
            reminder_offset = timedelta(minutes=30)
        
        # Create a datetime object for the activity
        activity_datetime = timezone.make_aware(
            timezone.datetime.combine(activity.scheduled_date, activity.scheduled_start_time)
        )
        
        # Calculate when reminder should be sent
        reminder_time = activity_datetime - reminder_offset
        
        # If it's time to send the reminder (and activity hasn't started yet)
        if now >= reminder_time and now < activity_datetime:
            # Prepare reminder data
            reminder_data = {
                'id': activity.activity_id,
                'name': activity.activity_name,
                'description': activity.activity_desc,
                'scheduled_date': activity.scheduled_date.isoformat(),
                'start_time': activity.scheduled_start_time.isoformat(),
                'end_time': activity.scheduled_end_time.isoformat(),
                'status': activity.status
            }
            
            # Send to user's channel group
            async_to_sync(channel_layer.group_send)(
                f'user_{activity.student_id.student_id}',
                {
                    'type': 'reminder_notification',
                    'reminder_type': 'activity',
                    'reminder': reminder_data
                }
            )
            
            # Mark as sent
            activity.reminder_sent = True
            activity.save()

def send_goal_reminders():
    """Check for goal progress reminders and send notifications"""
    now = timezone.now()
    today = now.date()
    
    # Get all active goals that haven't had reminders sent today
    active_goals = Goals.objects.filter(
        student_id__is_active=True,
        last_reminder_date__lt=today  # No reminder sent today
    ).select_related('student_id')
    
    channel_layer = get_channel_layer()
    
    for goal in active_goals:
        # Check if it's time to send a reminder based on timeframe
        send_reminder = False
        
        if goal.timeframe == 'Daily':
            # Send daily reminder
            send_reminder = True
        elif goal.timeframe == 'Weekly' and today.weekday() == 0:  # Monday
            # Send weekly reminder on Mondays
            send_reminder = True
        elif goal.timeframe == 'Monthly' and today.day == 1:  # First day of month
            # Send monthly reminder on first day of month
            send_reminder = True
            
        if send_reminder:
            # Get scheduled goal sessions for today
            today_goal_schedules = GoalSchedule.objects.filter(
                goal_id=goal,
                scheduled_date=today,
                status='Pending'
            )
            
            # If there are scheduled sessions today, remind the user
            if today_goal_schedules.exists():
                # Prepare reminder data
                reminder_data = {
                    'id': goal.goal_id,
                    'name': goal.goal_name,
                    'description': goal.goal_desc,
                    'type': goal.goal_type,
                    'target_hours': goal.target_hours,
                    'timeframe': goal.timeframe,
                    'sessions_today': [
                        {
                            'id': sched.goalschedule_id,
                            'start_time': sched.scheduled_start_time.isoformat(),
                            'end_time': sched.scheduled_end_time.isoformat()
                        } for sched in today_goal_schedules
                    ]
                }
                
                # Send to user's channel group
                async_to_sync(channel_layer.group_send)(
                    f'user_{goal.student_id.student_id}',
                    {
                        'type': 'reminder_notification',
                        'reminder_type': 'goal',
                        'reminder': reminder_data
                    }
                )
                
                # Update last reminder date
                goal.last_reminder_date = today
                goal.save()

def send_wake_up_reminders():
    """Check and send wake-up reminders"""
    now = timezone.now()
    today = now.date()
    
    # Get all user preferences
    user_prefs = UserPref.objects.filter(
        student_id__is_active=True
    ).select_related('student_id')
    
    channel_layer = get_channel_layer()
    
    for pref in user_prefs:
        # Create datetime objects for wake-up time today
        wake_time = timezone.make_aware(
            timezone.datetime.combine(today, pref.usual_wake_time)
        )
        
        # If it's within 5 minutes of wake-up time
        if now <= wake_time and now >= (wake_time - timedelta(minutes=5)):
            # Format the wake time nicely
            formatted_wake_time = wake_time.strftime('%I:%M %p')
            
            # Send to user's channel group
            async_to_sync(channel_layer.group_send)(
                f'user_{pref.student_id.student_id}',
                {
                    'type': 'reminder_notification',
                    'reminder_type': 'wake',
                    'reminder': f"Good morning! It's time to wake up. Your scheduled wake-up time is {formatted_wake_time}."
                }
            )


@shared_task
def send_all_reminders():
    """Master function to check and send all types of reminders"""
    print('Starting reminder checks...')
    
    try:
        send_task_reminders()
        print('Task reminders processed')
    except Exception as e:
        print(f'Error processing task reminders: {str(e)}')
    
    try:
        send_event_reminders()
        print('Event reminders processed')
    except Exception as e:
        print(f'Error processing event reminders: {str(e)}')
    
    try:
        send_activity_reminders()
        print('Activity reminders processed')
    except Exception as e:
        print(f'Error processing activity reminders: {str(e)}')
    
    try:
        send_class_reminders()
        print('Class reminders processed')
    except Exception as e:
        print(f'Error processing class reminders: {str(e)}')
    
    try:
        send_sleep_reminders()
        print('Sleep reminders processed')
    except Exception as e:
        print(f'Error processing sleep reminders: {str(e)}')
    
    try:
        send_wake_up_reminders()
        print('Wake-up reminders processed')
    except Exception as e:
        print(f'Error processing wake-up reminders: {str(e)}')
    
    try:
        send_goal_reminders()
        print('Goal reminders processed')
    except Exception as e:
        print(f'Error processing goal reminders: {str(e)}')
    
    print('All reminder checks completed')
    return True