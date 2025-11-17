from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from django.core.cache import cache
from .models import (
    CustomTask, CustomActivity, CustomEvents, Goals, UserPref, 
    CustomClassSchedule, CustomSemester, ScheduleEntry
)   

# def invalidate_dashboard(student_id):
#     print("CACHE INVALIDATED FOR:", student_id)
#     cache.delete(f"dashboard:{student_id}")


# # ---------------------------
# #   CUSTOM TASK
# # ---------------------------
# @receiver(post_save, sender=CustomTask)
# @receiver(post_delete, sender=CustomTask)
# def invalidate_task(sender, instance, **kwargs):
#     invalidate_dashboard(instance.student_id)


# # ---------------------------
# #   CUSTOM ACTIVITY
# # ---------------------------
# @receiver(post_save, sender=CustomActivity)
# @receiver(post_delete, sender=CustomActivity)
# def invalidate_activity(sender, instance, **kwargs):
#     invalidate_dashboard(instance.student_id)


# # ---------------------------
# #   CUSTOM EVENTS
# # ---------------------------
# @receiver(post_save, sender=CustomEvents)
# @receiver(post_delete, sender=CustomEvents)
# def invalidate_events(sender, instance, **kwargs):
#     invalidate_dashboard(instance.student_id)


# # ---------------------------
# #   GOALS
# # ---------------------------
# @receiver(post_save, sender=Goals)
# @receiver(post_delete, sender=Goals)
# def invalidate_goals(sender, instance, **kwargs):
#     invalidate_dashboard(instance.student_id)


# # ---------------------------
# #   USER PREF
# # ---------------------------
# @receiver(post_save, sender=UserPref)
# @receiver(post_delete, sender=UserPref)
# def invalidate_userpref(sender, instance, **kwargs):
#     invalidate_dashboard(instance.student_id)


# # ---------------------------
# #   CLASS SCHEDULE
# # ---------------------------
# @receiver(post_save, sender=CustomClassSchedule)
# @receiver(post_delete, sender=CustomClassSchedule)
# def invalidate_classschedule(sender, instance, **kwargs):
#     invalidate_dashboard(instance.student_id)


# # Extra rule: delete related schedule entries on class schedule deletion
# @receiver(post_delete, sender=CustomClassSchedule)
# def delete_schedule_entries(sender, instance, **kwargs):
#     ScheduleEntry.objects.filter(
#         category_type='Class',
#         reference_id=instance.classsched_id,
#         student_id=instance.student_id,
#     ).delete()


# # ---------------------------
# #   SEMESTER
# # ---------------------------
# @receiver(post_save, sender=CustomSemester)
# @receiver(post_delete, sender=CustomSemester)
# def invalidate_semester(sender, instance, **kwargs):
#     invalidate_dashboard(instance.student_id)


# Delete Schedule Entry for Custom Class Schedule
@receiver(post_delete, sender=CustomClassSchedule)
def delete_schedule_entries(sender, instance, **kwargs):
    ScheduleEntry.objects.filter(
        category_type='Class',
        reference_id=instance.classsched_id,
        student_id=instance.student_id
    ).delete()