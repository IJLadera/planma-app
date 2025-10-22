from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync
from django.utils import timezone
from django.conf import settings
from datetime import timedelta
from celery import shared_task
from firebase_admin import messaging
import redis
import os
import json
from .models import (
    CustomEvents, UserPref, CustomTask, CustomClassSchedule, CustomActivity,
    Goals, GoalSchedule, CustomUser, FCMToken
)

def is_user_in_foreground(user_id):
    r = redis.Redis.from_url(os.getenv("REDIS_URL"), ssl_cert_reqs=None)
    key = f"user_online:{user_id}"
    if not r.exists(key):
        return False
    try:
        data = json.loads(r.get(key))
        return data.get("foreground", False)
    except:
        return False

# In-App Reminders
def send_sleep_reminders():
    """Check for sleep reminders and send notifications"""

    now = timezone.now()
    today = now.date()

    # Get all user preferences
    user_prefs = UserPref.objects.filter(student_id=student_id)

    channel_layer = get_channel_layer()

    print(f"[SLEEP IN-APP] Found {user_prefs.count()} upcoming sleep to evaluate at {now}")

    for pref in user_prefs:
        print(f"[SLEEP IN-APP] Pref ID={pref.pref_id}, Sleep Time={pref.usual_sleep_time}")

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
        print(f"[SLEEP IN-APP] Reminder time for 'Sleep': {reminder_time}")

        # If it's time to send the reminder
        if now >= reminder_time and now <= sleep_time:
            student_id = pref.student_id.student_id
            # Format the sleep time nicely
            formatted_sleep_time = sleep_time.strftime('%I:%M %p')

            # Send to user's channel group
            if is_user_in_foreground(student_id):
                async_to_sync(channel_layer.group_send)(
                    f'user_{pref.student_id.student_id}',
                    {
                        'type': 'reminder_notification',
                        'reminder_type': 'sleep',
                        'reminder': f"Time to prepare for bed - you should be asleep by {formatted_sleep_time}"
                    }
                )
                print(f"[SLEEP IN-APP] Sending in-app to {student_id}")
                # Update last reminder date
                pref.last_sleep_reminder_date = today
                pref.save()

def send_task_reminders():
    """Check for task reminders and send notifications"""
    now = timezone.now()
    today = now.date()

    # Get tasks that are due soon but haven't had reminders sent
    upcoming_tasks = CustomTask.objects.filter(
        reminder_sent=False,
        status__in=['Pending', 'In Progress'],
        scheduled_date__gte=today,
    ).select_related('student_id', 'subject_id')

    channel_layer = get_channel_layer()

    print(f"[TASK IN-APP] Found {upcoming_tasks.count()} upcoming tasks to evaluate at {now}")

    print('Channel Check')
    print(now)
    for task in upcoming_tasks:
        print(f"[TASK IN-APP] Task ID={task.task_id}, Name={task.task_name}")

        # Get user preferences for reminder timing
        try:
            user_pref = UserPref.objects.get(student_id=task.student_id)
            reminder_offset = user_pref.reminder_offset_time
        except UserPref.DoesNotExist:
            # Default to 30 minutes if no preference set
            reminder_offset = timedelta(minutes=30)

        # Calculate when reminder should be sent
        reminder_time = task.deadline - reminder_offset
        print(f"[TASK IN-APP] Reminder time for '{task.task_name}': {reminder_time}")

        # print('Time Check')
        # print(now) 
        # print(reminder_time) 
        # If it's time to send the reminder
        if now >= reminder_time:
            student_id = task.student_id.student_id
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
            if is_user_in_foreground(student_id):
                async_to_sync(channel_layer.group_send)(
                    f'user_{task.student_id.student_id}',
                    {
                        'type': 'reminder_notification',
                        'reminder_type': 'task',
                        'reminder': reminder_data
                    }
                )
                print(f"[TASK IN-APP] Sending in-app ush to {student_id}")
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

    print(f"[EVENT IN-APP] Found {upcoming_events.count()} upcoming events to evaluate at {now}")

    for event in upcoming_events:
        print(f"[EVENT IN-APP] Event ID={event.event_id}, Name={event.event_name}")
        
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
        print(f"[EVENT IN-APP] Reminder time for '{event.event_name}': {reminder_time}")
        
        # If it's time to send the reminder (and event hasn't started yet)
        if now >= reminder_time and now < event_datetime:
            student_id = event.student_id.student_id
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
            if is_user_in_foreground(student_id):
                async_to_sync(channel_layer.group_send)(
                    f'user_{event.student_id.student_id}',
                    {
                        'type': 'reminder_notification',
                        'reminder_type': 'event',
                        'reminder': reminder_data
                    }
                )
                print(f"[EVENT IN-APP] Sending in-app to {student_id}")
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

    print(f"[CLASS IN-APP] Found {class_schedules.count()} upcoming classes to evaluate at {now}")
    
    for class_schedule in class_schedules:
        print(f"[CLASS IN-APP] Class ID={class_schedule.classsched_id}, Name={class_schedule.subject.subject_code}")

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
        print(f"[CLASS IN-APP] Reminder time for '{class_schedule.subject.subject_code}': {reminder_time}")
        
        # If it's time to send the reminder (and class hasn't started yet)
        if now >= reminder_time and now < class_datetime:
            student_id = class_schedule.student_id.student_id
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
            if is_user_in_foreground(student_id):
                async_to_sync(channel_layer.group_send)(
                    f'user_{class_schedule.student_id.student_id}',
                    {
                        'type': 'reminder_notification',
                        'reminder_type': 'class',
                        'reminder': reminder_data
                    }
                )
                print(f"[CLASS IN-APP] Sending in-app to {student_id}")
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

    print(f"[ACTIVITY IN-APP] Found {upcoming_activities.count()} upcoming activities to evaluate at {now}")
    
    for activity in upcoming_activities:
        print(f"[ACTIVITY IN-APP] Activity ID={activity.activity_id}, Name={activity.activity_name}")

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
        print(f"[ACTIVITY IN-APP] Reminder time for '{activity.activity_name}': {reminder_time}")
        
        # If it's time to send the reminder (and activity hasn't started yet)
        if now >= reminder_time and now < activity_datetime:
            student_id = activity.student_id.student_id
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
            if is_user_in_foreground(student_id):
                async_to_sync(channel_layer.group_send)(
                    f'user_{activity.student_id.student_id}',
                    {
                        'type': 'reminder_notification',
                        'reminder_type': 'activity',
                        'reminder': reminder_data
                    }
                )
                print(f"[ACTIVITY IN-APP] Sending in-app to {student_id}")
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

    print(f"[GOAL IN-APP] Found {active_goals.count()} upcoming goals to evaluate at {now}")
    
    for goal in active_goals:
        print(f"[GOAL IN-APP] Goal ID={goal.goal_id}, Name={goal.goal_name}")

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
                student_id = goal.student_id.student_id
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
                if is_user_in_foreground(student_id):
                    async_to_sync(channel_layer.group_send)(
                        f'user_{goal.student_id.student_id}',
                        {
                            'type': 'reminder_notification',
                            'reminder_type': 'goal',
                            'reminder': reminder_data
                        }
                    )
                    print(f"[GOAL IN-APP] Sending in-app to {student_id}")
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

    print(f"[WAKE IN-APP] Found {user_prefs.count()} upcoming wake to evaluate at {now}")
    
    for pref in user_prefs:
        print(f"[WAKE IN-APP] Pref ID={pref.pref_id}, Name={pref.usual_wake_time}")

        # Create datetime objects for wake-up time today
        wake_time = timezone.make_aware(
            timezone.datetime.combine(today, pref.usual_wake_time)
        )
        print(f"[WAKE IN-APP] Reminder time for 'Wake Up': {wake_time}")
        
        # If it's within 5 minutes of wake-up time
        if now <= wake_time and now >= (wake_time - timedelta(minutes=5)):
            student_id = pref.student_id.student_id
            # Format the wake time nicely
            formatted_wake_time = wake_time.strftime('%I:%M %p')
            
            # Send to user's channel group
            if is_user_in_foreground(student_id):
                async_to_sync(channel_layer.group_send)(
                    f'user_{pref.student_id.student_id}',
                    {
                        'type': 'reminder_notification',
                        'reminder_type': 'wake',
                        'reminder': f"Good morning! It's time to wake up. Your scheduled wake-up time is {formatted_wake_time}."
                    }
                )
                print(f"[WAKE IN-APP] Sending in-app to {student_id}")


# Push Notifications
def send_sleep_push_reminders():
    now = timezone.now()
    today = now.date()

    user_prefs = UserPref.objects.filter(
        student_id__is_active=True
    ).select_related('student_id')

    print(f"[SLEEP PUSH] Found {user_prefs.count()} upcoming sleep to evaluate at {now}")

    sent_tokens = set()

    for pref in user_prefs:
        print(f"[SLEEP PUSH] Pref ID={pref.pref_id}, Time={pref.usual_sleep_time}")

        sleep_time = timezone.make_aware(
            timezone.datetime.combine(today, pref.usual_sleep_time)
        )
        
        reminder_offset = pref.reminder_offset_time or timedelta(minutes=30)
        reminder_time = sleep_time - reminder_offset
        print(f"[SLEEP PUSH] Reminder time for 'Sleep': {reminder_time}")

        # Skip if a reminder was already sent one today
        if pref.last_sleep_reminder_date == today:
            continue

        if now >= reminder_time and now <= sleep_time:
            student_id = pref.student_id.student_id
            if not is_user_in_foreground(student_id):
                token = getattr(pref.student_id, "fcm_token", None)
                if token and token not in sent_tokens:
                    sent_tokens.add(token)
                    title = "Sleep Reminder"
                    body = f"You should be asleep by {sleep_time.strftime('%I:%M %p')}."
                
                    print(f"[SLEEP PUSH] Sending push to {student_id}: {title} - {body}")
                    send_push_notification.delay(student_id, title, body)

                    pref.last_sleep_reminder_date = today
                    pref.save()

def send_task_push_reminders():
    now = timezone.now()
    today = now.date()

    upcoming_tasks = CustomTask.objects.filter(
        reminder_sent=False,
        status__in=['Pending', 'In Progress'],
        scheduled_date__gte=today,
    ).select_related('student_id', 'subject_id')

    print(f"[TASK PUSH] Found {upcoming_tasks.count()} upcoming tasks to evaluate at {now}")

    for task in upcoming_tasks:
        print(f"[TASK PUSH] Task ID={task.task_id}, Name={task.task_name}")

        try:
            user_pref = UserPref.objects.get(student_id=task.student_id)
            reminder_offset = user_pref.reminder_offset_time
        except UserPref.DoesNotExist:
            reminder_offset = timedelta(minutes=30)

        reminder_time = task.deadline - reminder_offset
        print(f"[TASK PUSH] Reminder time for '{task.task_name}': {reminder_time}")

        if now >= reminder_time:
            student_id = task.student_id.student_id

            if not is_user_in_foreground(student_id):
                subject_name = task.subject_id.subject_title if task.subject_id else "No subject"
                message = f"{task.task_name} is due soon! Subject: {subject_name}"
                title = "Task Reminder"

                print(f"[TASK PUSH] Sending push to {student_id}: {title} - {message}")
                send_push_notification.delay(student_id, title, message)

                # Mark as sent so it doesn't send again
                task.reminder_sent = True
                task.save()

def send_event_push_reminders():
    now = timezone.now()
    today = now.date()

    upcoming_events = CustomEvents.objects.filter(
        reminder_sent=False,
        scheduled_date__gte=today
    ).select_related('student_id')

    print(f"[EVENT PUSH] Found {upcoming_events.count()} upcoming events to evaluate at {now}")

    for event in upcoming_events:
        print(f"[EVENT PUSH] Event ID={event.event_id}, Name={event.event_name}")

        try:
            user_pref = UserPref.objects.get(student_id=event.student_id)
            reminder_offset = user_pref.reminder_offset_time
        except UserPref.DoesNotExist:
            reminder_offset = timedelta(minutes=30)

        event_datetime = timezone.make_aware(
            timezone.datetime.combine(event.scheduled_date, event.scheduled_start_time)
        )
        reminder_time = event_datetime - reminder_offset
        print(f"[EVENT PUSH] Reminder time for '{event.event_name}': {reminder_time}")

        if now >= reminder_time and now < event_datetime:
            student_id = event.student_id.student_id

            if not is_user_in_foreground(student_id):
                title = "Event Reminder"
                body = f"{event.event_name} starts soon at {event.scheduled_start_time.strftime('%I:%M %p')}."

                print(f"[EVENT PUSH] Sending push to {student_id}: {title} - {body}")
                send_push_notification.delay(student_id, title, body)

                event.reminder_sent = True
                event.save()

def send_class_push_reminders():
    now = timezone.now()
    today = now.date()
    current_day = today.strftime("%A")

    class_schedules = CustomClassSchedule.objects.filter(
        day_of_week=current_day,
        last_reminder_date__lt=today
    ).select_related('student_id', 'subject')

    print(f"[CLASS PUSH] Found {class_schedules.count()} upcoming classes to evaluate at {now}")

    for class_schedule in class_schedules:
        print(f"[CLASS PUSH] Class ID={class_schedule.classsched_id}, Name={class_schedule.subject.subject_code}")

        try:
            user_pref = UserPref.objects.get(student_id=class_schedule.student_id)
            reminder_offset = user_pref.reminder_offset_time
        except UserPref.DoesNotExist:
            reminder_offset = timedelta(minutes=30)

        class_datetime = timezone.make_aware(
            timezone.datetime.combine(today, class_schedule.scheduled_start_time)
        )
        reminder_time = class_datetime - reminder_offset
        print(f"[CLASS PUSH] Reminder time for '{class_schedule.subject.subject_code}': {reminder_time}")

        if now >= reminder_time and now < class_datetime:
            student_id = class_schedule.student_id.student_id

            if not is_user_in_foreground(student_id):
                title = f"Class Reminder"
                body = f"Your class in {class_schedule.subject.subject_code} starts at {class_schedule.scheduled_start_time.strftime('%I:%M %p')} in {class_schedule.room}."

                print(f"[CLASS PUSH] Sending push to {student_id}: {title} - {body}")
                send_push_notification.delay(student_id, title, body)

                class_schedule.last_reminder_date = today
                class_schedule.save()

def send_activity_push_reminders():
    now = timezone.now()
    today = now.date()

    upcoming_activities = CustomActivity.objects.filter(
        reminder_sent=False,
        status__in=['Pending', 'In Progress'],
        scheduled_date__gte=today
    ).select_related('student_id')

    print(f"[ACTIVITY PUSH] Found {upcoming_activities.count()} upcoming activities to evaluate at {now}")

    for activity in upcoming_activities:
        print(f"[ACTIVITY PUSH] Activity ID={activity.activity_id}, Name={activity.activity_name}")

        try:
            user_pref = UserPref.objects.get(student_id=activity.student_id)
            reminder_offset = user_pref.reminder_offset_time
        except UserPref.DoesNotExist:
            reminder_offset = timedelta(minutes=30)

        activity_datetime = timezone.make_aware(
            timezone.datetime.combine(activity.scheduled_date, activity.scheduled_start_time)
        )
        reminder_time = activity_datetime - reminder_offset
        print(f"[ACTIVITY PUSH] Reminder time for '{activity.activity_name}': {reminder_time}")

        if now >= reminder_time and now < activity_datetime:
            student_id = activity.student_id.student_id

            if not is_user_in_foreground(student_id):
                title = "Activity Reminder"
                body = f"{activity.activity_name} starts at {activity.scheduled_start_time.strftime('%I:%M %p')}."

                print(f"[ACTIVITY PUSH] Sending push to {student_id}: {title} - {body}")
                send_push_notification.delay(student_id, title, body)

                activity.reminder_sent = True
                activity.save()

def send_goal_push_reminders():
    now = timezone.now()
    today = now.date()

    active_goals = Goals.objects.filter(
        student_id__is_active=True,
        last_reminder_date__lt=today
    ).select_related('student_id')

    print(f"[GOAL PUSH] Found {active_goals.count()} upcoming goals to evaluate at {now}")

    for goal in active_goals:
        print(f"[GOAL PUSH] Goal ID={goal.goal_id}, Name={goal.goal_name}")

        send_reminder = False
        if goal.timeframe == 'Daily':
            send_reminder = True
        elif goal.timeframe == 'Weekly' and today.weekday() == 0:
            send_reminder = True
        elif goal.timeframe == 'Monthly' and today.day == 1:
            send_reminder = True

        if send_reminder:
            today_goal_schedules = GoalSchedule.objects.filter(
                goal_id=goal,
                scheduled_date=today,
                status='Pending'
            )
            if today_goal_schedules.exists():
                student_id = goal.student_id.student_id

                if not is_user_in_foreground(student_id):
                    title = "Goal Reminder"
                    body = f"You have a goal session today for \"{goal.goal_name}\"."

                    print(f"[GOAL PUSH] Sending push to {student_id}: {title} - {body}")
                    send_push_notification.delay(student_id, title, body)

                    goal.last_reminder_date = today
                    goal.save()

def send_wake_up_push_reminders():
    now = timezone.now()
    today = now.date()

    user_prefs = UserPref.objects.filter(
        student_id__is_active=True
    ).select_related('student_id')

    print(f"[WAKE PUSH] Found {user_prefs.count()} upcoming wake to evaluate at {now}")

    sent_tokens = set()

    for pref in user_prefs:
        print(f"[WAKE PUSH] Pref ID={pref.pref_id}, Time={pref.usual_wake_time}")

        wake_time = timezone.make_aware(
            timezone.datetime.combine(today, pref.usual_wake_time)
        )
        print(f"[WAKE PUSH] Reminder time for 'Wake Up': {wake_time}")

        if now <= wake_time and now >= (wake_time - timedelta(minutes=5)):
            student_id = pref.student_id.student_id

            if not is_user_in_foreground(student_id):
                token = getattr(pref.student_id, "fcm_token", None)
                if token and token not in sent_tokens:
                    sent_tokens.add(token)
                    title = "Wake-Up Reminder"
                    body = f"Good morning! Your scheduled wake-up time is {wake_time.strftime('%I:%M %p')}."

                    print(f"[WAKE PUSH] Sending push to {student_id}: {title} - {body}")
                    send_push_notification.delay(student_id, title, body)

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

    try:
        send_sleep_push_reminders()
        print('Sleep push reminders processed')
    except Exception as e:
        print(f'Error processing sleep PUSH reminders: {str(e)}')

    try:
        send_task_push_reminders()
        print('Task push reminders processed')
    except Exception as e:
        print(f'Error processing task PUSH reminders: {str(e)}')

    try:
        send_event_push_reminders()
        print('Event push reminders processed')
    except Exception as e:
        print(f'Error processing event PUSH reminders: {str(e)}')

    try:
        send_class_push_reminders()
        print('Class push reminders processed')
    except Exception as e:
        print(f'Error processing class PUSH reminders: {str(e)}')

    try:
        send_activity_push_reminders()
        print('Activity PUSH reminders processed')
    except Exception as e:
        print(f'Error processing activity PUSH reminders: {str(e)}')

    try:
        send_goal_push_reminders()
        print('Goal PUSH reminders processed')
    except Exception as e:
        print(f'Error processing goal PUSH reminders: {str(e)}')

    try:
        send_wake_up_push_reminders()
        print('Wake-up PUSH reminders processed')
    except Exception as e:
        print(f'Error processing wake-up PUSH reminders: {str(e)}')
    
    print('All reminder checks completed')
    return True

  
@shared_task
def send_push_notification(user_id, title, message):
    try:
        token = FCMToken.objects.get(user_id=user_id).token

        # Build the message payload
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=message
            ),
            token=token
        )

        print(f"📦 Sending FCM payload to {user_id}: {message}")
        response = messaging.send(message)
        print(f'Push notification sent to user {user_id}: {response}')
        return response

    except FCMToken.DoesNotExist:
        print(f"No FCM token found for user {user_id}")
        return None
    except Exception as e:
        print(f"Error sending notification to user {user_id}: {str(e)}")
        return None
