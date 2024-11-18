from django.db import models
from django.contrib.auth.models import AbstractBaseUser,PermissionsMixin
from django.contrib.auth.base_user import BaseUserManager
import uuid
from django.conf import settings


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
    is_staff=models.BooleanField(default=False)
    

    is_active = models.BooleanField(default=True)

    objects = AppUserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['firstname', 'lastname','username']
    objects = AppUserManager()

    def str(self):
        return self.email
    

class CustomTask(models.Model):
    # Primary Key
    task_id = models.AutoField(primary_key=True)
    
    # Task Details
    task_name = models.CharField(max_length=255)
    task_desc = models.TextField()
    scheduled_date = models.DateField()
    scheduled_start_time = models.TimeField()
    scheduled_end_time = models.TimeField()
    deadline = models.DateTimeField()
    status = models.CharField(max_length=50)
    subject_code = models.CharField(max_length=50)
    
    # Foreign Key to CustomUser model
    student_id = models.ForeignKey(
        CustomUser, 
        on_delete=models.CASCADE, 
        related_name='tasks', db_column="student_id"
    )

    def __str__(self):
        return self.task_name

class CustomEvents(models.Model):
    
     # Primary Key
    event_id = models.AutoField(primary_key=True)
    
    # Event Details
    event_name = models.CharField(max_length=255)
    event_desc = models.TextField()
    location = models.TextField()
    scheduled_date = models.DateField()
    scheduled_start_time = models.TimeField()
    scheduled_end_time = models.TimeField()
    event_type = models.CharField(max_length=50)  # You can input the type of event, which can vary alot
    # Foreign Key to CustomUser model
    student_id = models.ForeignKey(
        CustomUser,
        on_delete=models.CASCADE,
        related_name='events', db_column="student_id"
    )
    def __str__(self):
        return self.event_name
class AttendedEvents(models.Model):
    
     # Primary Key
    att_events_id = models.AutoField(primary_key=True)
    
    # Attended Events Details
    # Foreign Key
    event_id = models.ForeignKey(
    CustomEvents,  # This links to your custom user model
    on_delete=models.CASCADE,
    related_name='att_Ev', db_column="event_id"
    )
    date = models.DateField()
    has_attended = models.BooleanField()  # True and False
class CustomActivity(models.Model):
    
     # Primary Key
    activity_id = models.AutoField(primary_key=True)
    
    # Activity Details
    activity_name = models.CharField(max_length=255)
    activity_desc = models.TextField()
    scheduled_date = models.DateField()
    scheduled_start_time = models.TimeField()
    scheduled_end_time = models.TimeField()
    status = models.CharField(max_length=50) 
    # Foreign Key
    student_id = models.ForeignKey(
        CustomUser,  # This links to your custom user model
        on_delete=models.CASCADE,
        related_name='activity', db_column='student_id'
    )
    def __str__(self):
        return self.activity_name
    
class ActivityLog(models.Model):
    
     # Primary Key
    act_log_id = models.AutoField(primary_key=True)
    
    # Activity Details
    # Foreign Key
    activity_id = models.ForeignKey(
        CustomActivity,  # This links to your custom user model
        on_delete=models.CASCADE,
        related_name='actlog', db_column='activity_id'
    )
    start_time = models.TimeField()
    end_time = models.TimeField()
    #duration = models.DurationField()
    duration = models.TimeField() # Struggling in determining whether this should be a time field or a duration field
    date_logged = models.DateField()

class UserPref(models.Model):
    
     # Primary Key
    pref_id = models.AutoField(primary_key=True)
    
    # User Pref Details
    usual_sleep_time = models.TimeField()
    usual_wake_time = models.TimeField()
    notification_enabled = models.BooleanField() # Struggling in determining whether this should be a time field or a duration field
    reminder_offset_time = models.TimeField()
    student_id = models.ForeignKey(
        CustomUser,  # This links to your custom user model
        on_delete=models.CASCADE,
        related_name='userpref', db_column='student_id'
    )

class CustomSub(models.Model):
    #Primary Key
    #subject_id = models.AutoField(primary_key=True) #mainly for database classification, not integration with frontend

    #Subject Details
    subject_code = models.CharField(max_length=20, primary_key=True)
    subject_title = models.TextField()
    student_id = models.ForeignKey(
        CustomUser,  # This links to your custom user model
        on_delete=models.CASCADE,
        related_name='subject', db_column='student_id'
    )
    semester_id = models.TextField() #Foreign Key for Semester, pending 


class CustomClass(models.Model):
    
     # Primary Key
    classsched_id = models.AutoField(primary_key=True)

    # Class Details
    subject_code = models.ForeignKey(
        CustomSub,  # This links to your custom user model
        on_delete=models.CASCADE,
        related_name='subject', db_column='subject_id'
    )
    day_of_week = models.IntegerField() #numbers with days of the week, 1 for sunday till 7 for saturday
    scheduled_start_time = models.TimeField()
    scheduled_end_time = models.TimeField()
    room = models.CharField(max_length=75)
    student_id = models.ForeignKey(
        CustomUser,  # This links to your custom user model
        on_delete=models.CASCADE,
        related_name='classes', db_column='student_id'
    )

class AttendedClass(models.Model):

    # Primary Key
    att_class_id = models.AutoField(primary_key=True)

    # Class Details
    classched_id = models.ForeignKey(
        CustomClass,  # This links to your custom class model
        on_delete=models.CASCADE,
        related_name='attendedclass', db_column='classsched_id'
    )
    date = models.DateField()
    isExcused = models.BooleanField()
    hasAttended = models.BooleanField()

class Goals(models.Model):

    # Primary Key
    goal_id = models.AutoField(primary_key=True)

    # Goal Details
    goal_name = models.CharField(max_length=100)
    target_hours = models.TimeField() #if this is merely target hours, then Time Field might not work since it is at max 23 hours
    timeframe = models.TimeField()
    goal_desc = models.TextField()
    goal_type = models.CharField(max_length=30)
    student_id = models.ForeignKey(
        CustomUser,  # This links to your custom class model
        on_delete=models.CASCADE,
        related_name='goals', db_column='student_id'
    )
    semester_id = models.TextField() #Foreign Key for Semester, pending 

class GoalProgress(models.Model):
    
    # Primary Key
    goalprogress_id = models.AutoField(primary_key=True)

    # Goal Progress Details
    goal_id = models.ForeignKey(
        Goals,  # This links to your custom class model
        on_delete=models.CASCADE,
        related_name='goalprog', db_column='goal_id'
    )
    scheduled_start_time = models.TimeField()
    scheduled_end_time = models.TimeField()
    session_duration = models.TimeField()


class GoalSchedule(models.Model):
    
    # Primary Key
    goalschedule_id = models.AutoField(primary_key=True)

    # Goal Progress Details
    goal_id = models.ForeignKey(
        Goals,  # This links to your custom class model
        on_delete=models.CASCADE,
        related_name='goalsched', db_column='goal_id'
    )
    scheduled_start_time = models.TimeField()
    scheduled_end_time = models.TimeField()

class Report(models.Model): #Unfinished as of now

    #Primary Key
    report_id = models.AutoField(primary_key=True)

    #Reports (Alot of Foreign Keys honestly)
    student_id = models.ForeignKey(
        CustomUser,  # This links to your custom user model
        on_delete=models.CASCADE,
        related_name='subject', db_column='student_id'
    )
    semester_id = models.TextField() #Will be Foreign Key
