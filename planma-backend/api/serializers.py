from rest_framework import serializers
from .models import *
from djoser.serializers import UserCreateSerializer, UserSerializer
from .models import CustomUser

class CustomUserCreateSerializer(UserCreateSerializer):
    class Meta(UserCreateSerializer.Meta):
        model = CustomUser
        fields = ('student_id', 'email', 'password', 'firstname', 'lastname', 'username')

class CustomUserSerializer(UserSerializer):
    class Meta(UserSerializer.Meta):
        model = CustomUser
        fields = ('student_id', 'username', 'firstname', 'lastname')




class CustomTaskSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomTask
        fields = [
            'task_id', 'task_name', 'task_desc', 
            'scheduled_date', 'scheduled_start_time', 
            'scheduled_end_time', 'deadline', 
            'status', 'subject_code', 'student_id'
        ]
        # read_only_fields = ['task_id', 'student_id']

class CustomEventSerializer(serializers.ModelSerializer):
    class Meta: 
        model = CustomEvents
        fields = ['event_id', 'event_name', 'event_desc', 
                  'location', 'scheduled_date', 'scheduled_start_time', 
                  'scheduled_end_time', 'event_type', 'student_id']
        extra_kwargs = {
            'student_id': {'required': True},
        }
        
class ListEventSerializer(serializers.ModelSerializer):
    class Meta: 
        model = CustomEvents
        fields = ['event_id', 'event_name', 'scheduled_start_time', 
                  'scheduled_end_time']
        
class AttendedEventSerializer(serializers.ModelSerializer):
    class Meta: 
        model = AttendedEvents
        fields = ['att_events_id','event_id', 'date', 'has_attended']

class CustomActivitySerializer(serializers.ModelSerializer):
    class Meta: 
        model = CustomActivity
        fields = ['activity_id', 'activity_name', 'activity_desc', 
                  'scheduled_date', 'scheduled_start_time', 
                  'scheduled_end_time', 'status', 'student_id']       
        extra_kwargs = {
            'student_id': {'required': True},
        }
        
class ListActivitySerializer(serializers.ModelSerializer):
    class Meta: 
        model = CustomEvents
        fields = ['activity_id', 'activity_name', 'scheduled_start_time', 
                  'scheduled_end_time']
        
class ActivityLogSerializer(serializers.ModelSerializer):
    class Meta: 
        model = ActivityLog
        fields = ['act_log_id', 'activity_id', 'start_time', 
                  'end_time', 'duration', 'date_logged']


class UserPrefSerializer(serializers.ModelSerializer):
    class Meta: 
        model = UserPref
        fields = ['pref_id', 'usual_sleep_time', 'usual_wake_time', 
                  'notification_enabled', 'reminder_offset_time', 
                  'student_id']
        

class CustomClassSerializer(serializers.ModelSerializer):
    class Meta: 
        model = CustomClass
        fields = ['classsched_id', 'subject_code', 'day_of_week',
                  'scheduled_start_time', 'scheduled_end_time',
                  'room', 'student_id']

class CustomSubSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomSub
        fields = ['subject_code', 'subject_title',
                  'student_id', 'semester_id']

class AttendedClassSerializer(serializers.ModelSerializer):
    class Meta: 
        model = AttendedClass
        fields = ['att_class_id', 'classsched_id', 'date', 
                  'isExcused', 'hasAttended']

class CustomSemesterSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomSemester
        fields = ['semester_id', 'acad_year_start', 'acad_year_end',
                  'year_level', 'semester', 'sem_start_date',
                  'sem_end_date']
    def validate(self, data):
        if data['acad_year_end'] <= data['acad_year_start']:
            raise serializers.ValidationError("Academic year end must be greater than start year.")
        if data['sem_start_date'] >= data['sem_end_date']:
            raise serializers.ValidationError("Start date must be before end date.")
        return data
                
class GoalsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Goals
        fields = ['goal_id', 'goal_name', 'target_hours', 
                  'timeframe', 'goal_desc', 'goal_type',
                  'student_id', 'semester_id']
        
class GoalProgressSerializer(serializers.ModelSerializer):
    class Meta:
        model = GoalProgress
        fields = ['goalprogress_id', 'goal_id', 'scheduled_start_time'
                  'scheduled_end_time', 'session_duration']
        
class GoalScheduleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Goals
        fields = ['goalschedule_id', 'goal_id', 'scheduled_start_time',
                  'scheduled_end_time']

class ReportsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Report
        fields = ['report_id', 'student_id', 'semester_id',
                  'count_activities_total', 'count_activities_finished',
                  'count_activities_missed', 'count_events_total', 
                  'count_events_attended', 'count_events_missed', 
                  'counts_events_academictype', 'count_events_personaltype',
                  'count_tasks_total', 'count_tasks_finished', 'count_tasks_missed',
                  'count_class_total', 'count_class_attended', 'count_class_excused',
                  'count_goals', 'count_sleep']