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
