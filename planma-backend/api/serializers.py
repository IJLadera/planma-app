from rest_framework import serializers
from .models import *
from djoser.serializers import UserCreateSerializer, UserSerializer
from .models import CustomUser
from django.db.models import Q
from django.db import transaction

class CustomUserCreateSerializer(UserCreateSerializer):
    class Meta(UserCreateSerializer.Meta):
        model = CustomUser
        fields = ('student_id', 'email', 'password', 'firstname', 'lastname', 'username')

class CustomUserSerializer(UserSerializer):
    profile_picture = serializers.ImageField(required=False, allow_null=True)

    class Meta(UserSerializer.Meta):
        model = CustomUser
        fields = ('student_id', 'username', 'firstname', 'lastname', 'profile_picture')  


class CustomEventSerializer(serializers.ModelSerializer):
    student_id = serializers.PrimaryKeyRelatedField(queryset=CustomUser.objects.all())

    class Meta: 
        model = CustomEvents
        fields = ['event_id', 'event_name', 'event_desc', 
                  'location', 'scheduled_date', 'scheduled_start_time', 
                  'scheduled_end_time', 'event_type', 'student_id']
        extra_kwargs = {
            'student_id': {'required': True},
        }
        read_only_fields = ['student_id']
        
class AttendedEventSerializer(serializers.ModelSerializer):
    event_id = CustomEventSerializer()

    class Meta: 
        model = AttendedEvents
        fields = ['att_events_id','event_id', 'date', 'has_attended']

class CustomActivitySerializer(serializers.ModelSerializer):
    student_id = serializers.PrimaryKeyRelatedField(queryset=CustomUser.objects.all())

    class Meta: 
        model = CustomActivity
        fields = ['activity_id', 'activity_name', 'activity_desc', 
                  'scheduled_date', 'scheduled_start_time', 
                  'scheduled_end_time', 'status', 'student_id']       
        extra_kwargs = {
            'student_id': {'required': True},
        }
        read_only_fields = ['student_id']
        
class ActivityLogSerializer(serializers.ModelSerializer):
    activity_id = CustomActivitySerializer()

    class Meta: 
        model = ActivityTimeLog
        fields = ['activity_log_id', 'activity_id', 'start_time', 
                  'end_time', 'duration', 'date_logged']

class UserPrefSerializer(serializers.ModelSerializer):
    class Meta: 
        model = UserPref
        fields = ['pref_id', 'usual_sleep_time', 'usual_wake_time', 
                  'reminder_offset_time', 'student_id']
        read_only_fields = ['student_id']
        
class CustomSemesterSerializer(serializers.ModelSerializer):
    student_id = serializers.PrimaryKeyRelatedField(queryset=CustomUser.objects.all())

    class Meta:
        model = CustomSemester
        fields = ['semester_id', 'acad_year_start', 'acad_year_end',
                  'year_level', 'semester', 'sem_start_date',
                  'sem_end_date', 'student_id']
        
    def validate(self, data):
        if data['acad_year_end'] <= data['acad_year_start']:
            raise serializers.ValidationError("Academic year end must be greater than start year.")
        if data['sem_start_date'] >= data['sem_end_date']:
            raise serializers.ValidationError("Start date must be before end date.")
        return data

class CustomSubjectSerializer(serializers.ModelSerializer):
    semester_id = CustomSemesterSerializer()

    class Meta:
        model = CustomSubject
        fields = ['subject_id', 'subject_code', 'subject_title',
                  'student_id', 'semester_id']

class CustomClassScheduleSerializer(serializers.ModelSerializer):
    subject = CustomSubjectSerializer()

    class Meta: 
        model = CustomClassSchedule
        fields = ['classsched_id', 'subject', 'day_of_week',
                  'scheduled_start_time', 'scheduled_end_time',
                  'room', 'student_id']
        read_only_fields = ['classsched_id']

class AttendedClassSerializer(serializers.ModelSerializer):
    classsched_id = CustomClassScheduleSerializer()

    class Meta: 
        model = AttendedClass
        fields = ['att_class_id', 'classsched_id', 'date', 
                  'status']
        read_only_fields = ['att_class_id']
        
class CustomTaskSerializer(serializers.ModelSerializer):
    subject_id = CustomSubjectSerializer()
    student_id = serializers.PrimaryKeyRelatedField(queryset=CustomUser.objects.all())

    class Meta:
        model = CustomTask
        fields = [
            'task_id', 'task_name', 'task_desc', 
            'scheduled_date', 'scheduled_start_time', 
            'scheduled_end_time', 'deadline', 
            'status', 'subject_id', 'student_id'
        ]
        read_only_fields = ['student_id']

class TaskLogSerializer(serializers.ModelSerializer):
    task_id = CustomTaskSerializer()

    class Meta:
        model = TaskTimeLog
        fields = [
            'task_log_id', 'task_id', 'start_time', 
            'end_time', 'duration', 'date_logged'
        ]
                
class GoalsSerializer(serializers.ModelSerializer):
    semester_id = CustomSemesterSerializer()
    student_id = serializers.PrimaryKeyRelatedField(queryset=CustomUser.objects.all())

    class Meta:
        model = Goals
        fields = ['goal_id', 'goal_name', 'target_hours', 
                  'timeframe', 'goal_desc', 'goal_type',
                  'student_id', 'semester_id']
        read_only_fields = ['student_id']

class GoalScheduleSerializer(serializers.ModelSerializer):
    goal_id = GoalsSerializer()

    class Meta:
        model = GoalSchedule
        fields = ['goalschedule_id', 'goal_id', 'scheduled_date','scheduled_start_time',
                  'scheduled_end_time', 'status']
        read_only_fields = ['goal_id']
        
class GoalProgressSerializer(serializers.ModelSerializer):
    goal_id = GoalsSerializer()
    goalschedule_id = GoalScheduleSerializer()

    class Meta:
        model = GoalProgress
        fields = ['goalprogress_id', 'goal_id', 'goalschedule_id', 
                  'session_date', 'session_start_time', 'session_end_time', 
                  'session_duration']

class SleepLogSerializer(serializers.ModelSerializer):
    student_id = serializers.PrimaryKeyRelatedField(queryset=CustomUser.objects.all())

    class Meta:
        model = SleepLog
        fields = ['sleep_log_id', 'student_id', 'start_time',
                  'end_time', 'duration', 'date_logged']
        
class ScheduleEntrySerializer(serializers.ModelSerializer):
    student_id = serializers.PrimaryKeyRelatedField(queryset=CustomUser.objects.all())

    class Meta:
        model = ScheduleEntry
        fields = ['entry_id', 'category_type', 'reference_id', 'student_id',
                  'scheduled_date', 'scheduled_start_time', 'scheduled_end_time']
        
    def get_reference(self, obj):
        CATEGORY_MODELS = {
            "Task": CustomTask,
            "Class": CustomClassSchedule,
            "Event": CustomEvents,
            "Activity": CustomActivity,
            "Goal": GoalSchedule,
        }
        model = CATEGORY_MODELS.get(obj.category_type)
        if model:
            try:
                instance = model.objects.get(pk=obj.reference_id)
                return self.get_category_serializer(obj.category_type)(instance).data
            except model.DoesNotExist:
                return None
        return None

    def get_category_serializer(self, category_type):
        CATEGORY_SERIALIZERS = {
            "Task": CustomTaskSerializer,
            "Class": CustomClassScheduleSerializer,
            "Event": CustomEventSerializer,
            "Activity": CustomActivitySerializer,
            "Goal": GoalScheduleSerializer,
        }
        return CATEGORY_SERIALIZERS.get(category_type)