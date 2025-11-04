from datetime import timedelta
from django.db import models
from django.forms import ValidationError
from django.utils import timezone
from django.contrib.auth.models import AbstractBaseUser,PermissionsMixin
from django.contrib.auth.base_user import BaseUserManager
import uuid
from django.conf import settings
from django_enumfield import enum

def user_directory_path(instance, filename):
    # file will be uploaded to MEDIA_ROOT/profile_pictures/<student_id>/<filename>
    return f'profile_pictures/{instance.student_id}/{filename}'

class AppUserManager(BaseUserManager):
    def create_user(self,firstname, lastname, email, username, password=None):
            if not email:
                raise ValueError('An Email is Required')
            if not password:
                raise ValueError('A Password is Required')

            email = self.normalize_email(email)
            user = self.model(firstname=firstname, lastname=lastname, email=email,username=username)

            user.set_password(password)
            user.save()

            return user  
        
    def create_superuser(self, firstname, lastname, email, username, password=None):
            if not email:
                raise ValueError('An email is required.')
            if not password:
                raise ValueError('A password is required.')

            user = self.create_user(firstname=firstname, lastname=lastname, email=email,username=username, password=password)

            user.is_superuser = True
            user.is_staff = True
            user.save()

            return user


class CustomUser(AbstractBaseUser,PermissionsMixin):
    student_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    firstname = models.CharField(max_length=50)
    lastname = models.CharField(max_length=50)
    email=models.EmailField(max_length=255,unique=True)
    username = models.CharField(max_length=50)
    password=models.CharField(max_length=288)
    profile_picture = models.URLField(max_length=500, blank=True, null=True)
    is_staff=models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    objects = AppUserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['firstname', 'lastname','username']

    def __str__(self):  # Fixed str method
        return self.email


class CustomEvents(models.Model):
     # Primary Key
    event_id = models.AutoField(primary_key=True)
    
    # Event Details
    event_name = models.CharField(max_length=255)
    event_desc = models.TextField(null=True, blank=True)
    location = models.TextField()
    scheduled_date = models.DateField()
    scheduled_start_time = models.TimeField()
    scheduled_end_time = models.TimeField()
    event_type = models.CharField(max_length=50)
    # Foreign Key to CustomUser model
    student_id = models.ForeignKey(
        CustomUser,
        on_delete=models.CASCADE,
        related_name='events', db_column="student_id"
    )

    # New attribute for tracking reminder
    reminder_sent = models.BooleanField(default=False)

    def delete(self, *args, **kwargs):
        # Manually delete related ScheduleEntry before deleting this task
        ScheduleEntry.objects.filter(category_type='Event', reference_id=self.event_id).delete()
        super().delete(*args, **kwargs)

    def __str__(self):
        return self.event_name


class AttendedEvents(models.Model):
     # Primary Key
    att_events_id = models.AutoField(primary_key=True)

    # Foreign Key to CustomEvents model
    event_id = models.ForeignKey(
    CustomEvents,
    on_delete=models.CASCADE,
    related_name='att_Ev', db_column="event_id"
    )
    date = models.DateField()
    has_attended = models.BooleanField()


class CustomActivity(models.Model):
    STATUS_CHOICES = [
        ('Pending', 'Pending'),
        ('In Progress', 'In Progress'),
        ('Completed', 'Completed'),
    ]
     # Primary Key
    activity_id = models.AutoField(primary_key=True)
    
    # Activity Details
    activity_name = models.CharField(max_length=255)
    activity_desc = models.TextField(null=True, blank=True)
    scheduled_date = models.DateField()
    scheduled_start_time = models.TimeField()
    scheduled_end_time = models.TimeField()
    status =  models.CharField(max_length=50, choices=STATUS_CHOICES)
    # Foreign Key to CustomUser model
    student_id = models.ForeignKey(
        CustomUser,
        on_delete=models.CASCADE,
        related_name='activity', db_column='student_id'
    )

    # New attribute for tracking reminder
    reminder_sent = models.BooleanField(default=False)

    def delete(self, *args, **kwargs):
        # Manually delete related ScheduleEntry before deleting this task
        ScheduleEntry.objects.filter(category_type='Activity', reference_id=self.activity_id).delete()
        super().delete(*args, **kwargs)

    def __str__(self):
        return self.activity_name
    

class ActivityTimeLog(models.Model):
    # Primary Key
    activity_log_id = models.AutoField(primary_key=True)
    
    # Foreign Key to CustomActivity model
    activity_id = models.ForeignKey(
        CustomActivity,
        on_delete=models.CASCADE,
        related_name='actlog', db_column='activity_id'
    )
    start_time = models.TimeField()
    end_time = models.TimeField()
    duration = models.DurationField()
    date_logged = models.DateField()


class UserPref(models.Model):
    # Primary Key
    pref_id = models.AutoField(primary_key=True)
    
    # User Pref Details
    usual_sleep_time = models.TimeField(default="23:00")
    usual_wake_time = models.TimeField(default="07:00")
    reminder_offset_time = models.DurationField()
    # Foreign Key to CustomUser model
    student_id = models.ForeignKey(
        CustomUser, 
        on_delete=models.CASCADE,
        related_name='userpref',
        db_column='student_id',
        db_index=True
    )

    # New field to track the last sleep reminder date
    last_sleep_reminder_date = models.DateField(null=True, blank=True)

    def __str__(self):
        return f"User Preferences for {self.student_id.username} | Student ID: {self.student_id.student_id}"

    def clean(self):
        if self.usual_sleep_time >= self.usual_wake_time:
            raise ValidationError("Sleep time must be before wake time.")
        
    def save(self, *args, **kwargs):
        # Ensure `reminder_offset_time` is stored as a timedelta
        if isinstance(self.reminder_offset_time, (int, float, str)):
            self.reminder_offset_time = timedelta(seconds=int(self.reminder_offset_time))
        super().save(*args, **kwargs)

    class Meta:
        verbose_name = "User Preference"
        verbose_name_plural = "User Preferences"


class CustomSemester(models.Model):
    YEAR_LEVEL_CHOICES = [
        ('1st Year', '1st Year'),
        ('2nd Year', '2nd Year'),
        ('3rd Year', '3rd Year'),
        ('4th Year', '4th Year'),
        ('5th Year', '5th Year'),
    ]
    SEMESTER_CHOICES = [
        ('1st Semester', '1st Semester'),
        ('2nd Semester', '2nd Semester'),
    ]   
    # Primary Key
    semester_id = models.AutoField(primary_key=True)

    # Semester Details
    acad_year_start = models.PositiveIntegerField()
    acad_year_end = models.PositiveIntegerField()
    year_level = models.CharField(max_length=9, choices=YEAR_LEVEL_CHOICES)
    semester = models.CharField(max_length=12, choices=SEMESTER_CHOICES)
    sem_start_date = models.DateField()
    sem_end_date = models.DateField()
    # Foreign Key to CustomUser model
    student_id = models.ForeignKey(
        CustomUser,
        on_delete=models.CASCADE,
        related_name='semesters', db_column='student_id'
    )

    def __str__(self):
        return f"{self.acad_year_start}-{self.acad_year_end} {self.semester}"


class CustomSubject(models.Model):
    #Primary Key
    subject_id = models.AutoField(primary_key=True)

    # Subject Details
    subject_code = models.CharField(max_length=20,)
    subject_title = models.CharField(max_length=255)
    # Foreign Key to CustomUser model
    student_id = models.ForeignKey(
        CustomUser,
        on_delete=models.CASCADE,
        related_name='subjects', db_column='student_id'
    )
    # Foreign Key to CustomSemester model
    semester_id = models.ForeignKey(
        CustomSemester,
        on_delete=models.CASCADE,
        related_name='subsems', db_column='semester_id'
    )

    class Meta:
        unique_together = ('subject_code', 'student_id', 'semester_id')

    def __str__(self):
        return f'{self.subject_code} - {self.subject_title}'


class CustomClassSchedule(models.Model):
    # Primary Key
    classsched_id = models.AutoField(primary_key=True)

    # Class Details
    # Foreign Key to CustomSubject model
    subject = models.ForeignKey(
        CustomSubject,
        on_delete=models.CASCADE,
        related_name='classes', db_column='subject_id'
    )
    day_of_week = models.CharField(max_length=10)
    scheduled_start_time = models.TimeField()
    scheduled_end_time = models.TimeField()
    room = models.CharField(max_length=75)
    # Foreign Key to CustomUser model
    student_id = models.ForeignKey(
        CustomUser,
        on_delete=models.CASCADE,
        related_name='scheduled_classes', db_column='student_id'
    )

    # Added this field to track send reminders for class schedules.
    last_reminder_date = models.DateField(null=True, blank=True)

    class Meta:
        unique_together = ('subject', 'day_of_week', 'scheduled_start_time', 'scheduled_end_time', 'room', 'student_id')

    def __str__(self):
        # < MIGHT CAUSE ISSUES >
        # Access the related CustomSubject's title
        subject_title = self.subject.subject_title
        return f"{self.subject.subject_code} - {subject_title} | {self.room} | {self.day_of_week}"


class AttendedClass(models.Model):
    STATUS_CHOICES = [
        ('Did Not Attend', 'Did Not Attend'),
        ('Excused', 'Excused'),
        ('Attended', 'Attended'),
    ]
    # Primary Key
    att_class_id = models.AutoField(primary_key=True)

    # Class Details
    classsched_id = models.ForeignKey(
        CustomClassSchedule,
        on_delete=models.CASCADE,
        related_name='attendedclass', db_column='classsched_id'
    )
    attendance_date = models.DateField(default=timezone.now)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES)

    class Meta:
        unique_together = ('classsched_id', 'attendance_date')


class CustomTask(models.Model):
    STATUS_CHOICES = [
        ('Pending', 'Pending'),
        ('In Progress', 'In Progress'),
        ('Completed', 'Completed'),
    ]
    # Primary Key
    task_id = models.AutoField(primary_key=True)
    
    # Task Details
    task_name = models.CharField(max_length=255)
    task_desc = models.TextField(null=True, blank=True)
    scheduled_date = models.DateField()
    scheduled_start_time = models.TimeField()
    scheduled_end_time = models.TimeField()
    deadline = models.DateTimeField()
    status = models.CharField(max_length=50, choices=STATUS_CHOICES, default='Pending')
    # Foreign Key to CustomSubject model
    subject_id = models.ForeignKey(
        CustomSubject,
        on_delete=models.CASCADE,
        related_name='subject', db_column='subject_id'
    )
    # Foreign Key to CustomUser model
    student_id = models.ForeignKey(
        CustomUser, 
        on_delete=models.CASCADE, 
        related_name='tasks', db_column="student_id"
    )

    reminder_sent = models.BooleanField(default=False)

    def delete(self, *args, **kwargs):
        # Manually delete related ScheduleEntry before deleting this task
        ScheduleEntry.objects.filter(category_type='Task', reference_id=self.task_id).delete()
        super().delete(*args, **kwargs)

    def __str__(self):
        return self.task_name
    

class TaskTimeLog(models.Model):
    # Primary Key
    task_log_id = models.AutoField(primary_key=True)

    # Task Time Log Details
    # Foreign Key to CustomTask model
    task_id = models.ForeignKey(
        CustomTask,
        on_delete=models.CASCADE,
        related_name='tasklog', db_column='task_id'
    )
    start_time = models.TimeField()
    end_time = models.TimeField()
    duration = models.DurationField()
    date_logged = models.DateField()


class Goals(models.Model):
    TYPE_CHOICES = [
        ('Academic', 'Academic'),
        ('Personal', 'Personal'),
    ]
    TIMEFRAME_CHOICES = [
        ('Daily', 'Daily'),
        ('Weekly', 'Weekly'),
        ('Monthly', 'Monthly'),
    ]
    # Primary Key
    goal_id = models.AutoField(primary_key=True)

    # Goal Details
    goal_name = models.CharField(max_length=100)
    target_hours = models.IntegerField()
    timeframe = models.CharField(max_length=20, choices=TIMEFRAME_CHOICES)
    goal_desc = models.TextField(null=True, blank=True)
    goal_type = models.CharField(max_length=30, choices=TYPE_CHOICES)
    # Foreign Key to CustomUser model
    student_id = models.ForeignKey(
        CustomUser,
        on_delete=models.CASCADE,
        related_name='goals', db_column='student_id'
    )
    # Foreign Key to CustomSemester model
    semester_id = models.ForeignKey(
        CustomSemester,
        on_delete=models.CASCADE,
        related_name='goalsems', db_column='semester_id',
        null=True,
        blank=True
    ) 

    # New field for tracking reminders
    last_reminder_date = models.DateField(null=True, blank=True)

    def __str__(self):
        return self.goal_name


class GoalSchedule(models.Model):
    STATUS_CHOICES = [
        ('Pending', 'Pending'),
        ('Completed', 'Completed'),
    ]
    # Primary Key
    goalschedule_id = models.AutoField(primary_key=True)

    # Goal Progress Details
    # Foreign Key to Goals model
    goal_id = models.ForeignKey(
        Goals,
        on_delete=models.CASCADE,
        related_name='goalsched', db_column='goal_id'
    )
    scheduled_date = models.DateField()
    scheduled_start_time = models.TimeField()
    scheduled_end_time = models.TimeField()
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='Pending')


class GoalProgress(models.Model):
    # Primary Key
    goalprogress_id = models.AutoField(primary_key=True)

    # Goal Progress Details
    # Foreign Key to Goals model
    goal_id = models.ForeignKey(
        Goals,
        on_delete=models.CASCADE,
        related_name='goalprog', db_column='goal_id'
    )
    goalschedule_id = models.ForeignKey(
        GoalSchedule,
        on_delete=models.CASCADE,
        related_name='progresslogs', db_column='goalschedule_id',
    )
    session_date = models.DateField()
    session_start_time = models.TimeField()
    session_end_time = models.TimeField()
    session_duration = models.DurationField() 


class SleepLog(models.Model):
    # Primary Key
    sleep_log_id = models.AutoField(primary_key=True)

    # Sleep Details
    # Foreign Key to CustomUser model
    student_id = models.ForeignKey(
        CustomUser,
        on_delete=models.CASCADE,
        related_name='sleep', db_column='student_id'
    )
    start_time = models.TimeField()
    end_time = models.TimeField()
    duration = models.DurationField()
    date_logged = models.DateField()


class ScheduleEntry(models.Model):
    CATEGORY_CHOICES = [
        ('Task', 'Task'),
        ('Class', 'Class'),
        ('Event', 'Event'),
        ('Activity', 'Activity'),
        ('Goal', 'Goal'),
    ]
    # Primary Key
    entry_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    category_type = models.CharField(max_length=50, choices=CATEGORY_CHOICES)
    reference_id = models.IntegerField()
    # Foreign Key to CustomUser model
    student_id = models.ForeignKey(
        CustomUser,
        on_delete=models.CASCADE,
        related_name='entry', db_column='student_id'
    )
    scheduled_date = models.DateField()
    scheduled_start_time = models.TimeField()
    scheduled_end_time = models.TimeField()

    class Meta:
        unique_together = ('student_id', 'scheduled_date', 'scheduled_start_time', 'scheduled_end_time', 'category_type', 'reference_id')


class FCMToken(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    token = models.TextField()
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.username}'s FCM Token"