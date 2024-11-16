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
        fields = ('student_id', 'email', 'firstname', 'lastname', 'username')




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
        

