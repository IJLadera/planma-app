from rest_framework import serializers
from api.models import CustomTask  

class CreateTaskSerializer(serializers.Serializer):
    
    class Meta:
        model = CustomTask
        fields = [ 'task_id','task_name','task_desc','scheduled_date','scheduled_start_time','scheduled_end_time','priority','deadline','status','subject_code','student']