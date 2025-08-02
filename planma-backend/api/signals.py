from django.db.models.signals import post_delete
from django.dispatch import receiver
from .models import CustomClassSchedule, ScheduleEntry

@receiver(post_delete, sender=CustomClassSchedule)
def delete_schedule_entries(sender, instance, **kwargs):
    ScheduleEntry.objects.filter(
        category_type='Class',
        reference_id=instance.classsched_id,
        student_id=instance.student_id
    ).delete()
