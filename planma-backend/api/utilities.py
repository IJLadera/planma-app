from .models import UserPref
from django.utils import timezone
from datetime import timedelta

def get_sleep_reminders(student_id: UserPref):
    
    now = timezone.now()
    today = now.date()

    # Get user preference for sleep time
    try:
        user_pref = UserPref.objects.get(student_id=student_id)

        # Skip if reminder already sent today
        if user_pref.last_sleep_reminder_date == today:
            return []
        
        sleep_time = user_pref.usual_sleep_time
        reminder_offset = user_pref.reminder_offset_time

        # Create a datetime object for sleep time
        sleep_datetime = timezone.make_aware(
            timezone.datetime.combine(today, sleep_time)
        )

        # Calculate when reminder should be sent
        reminder_time = sleep_datetime - reminder_offset

        # If it's time to send the reminder
        if now >= reminder_time and now < sleep_datetime:
            # Mark as sent for today
            user_pref.last_sleep_reminder_date = today
            user_pref.save()

            return [
                {
                    'sleep_time': sleep_time.isoformat(),
                    'message': "Time to prepare for sleep soon!"
                }
            ]
    except UserPref.DoesNotExist:
        pass

    return []
