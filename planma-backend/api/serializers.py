from rest_framework import serializers
from .models import *

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
                  'scheduled_date', 'scheduled_start_time', 'scheduled_end_time', 
                  'status', 'student_id']

class ListActivitySerializer(serializers.ModelSerializer):
    class Meta: 
        model = CustomEvents
        fields = ['activity_id', 'activity_name', 'scheduled_start_time', 
                  'scheduled_end_time']

class ActivityLogSerializer(serializers.ModelSerializer):
    class Meta: 
        model = ActivityLog
        fields = ['act_log_id', 'activity_id', 'start_time', 'end_time', 'duration', 'date_logged']
