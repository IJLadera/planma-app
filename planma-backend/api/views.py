from rest_framework.response import Response
from rest_framework import generics, permissions, status
from .models import *
from .serializers import *
from rest_framework.views import APIView



class CustomTaskListCreateView(APIView):
    
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        data = request.data
        serializer = CustomTaskSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response({**serializer.data}, status=status.HTTP_200_OK)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)
        # Set the student field to the authenticated user on creation
        

class CustomTaskDetailView(APIView):
   
    permission_classes = [permissions.AllowAny]

    def get(self,request,pk):
        
        user = CustomUser.objects.get(student_id = pk)
        task = CustomTask.objects.filter(student_id = user)
        serializer = CustomTaskSerializer(task, many = True)
        
        return Response(serializer.data)
    
class CustomTaskDeleteView(APIView):
    permission_classes = [permissions.AllowAny]
    
    def delete(self,request,pk):
        try:
            
            deletetask = CustomTask.objects.get(task_id = pk)
            
            deletetask.delete()
            
            return Response({"message : Post deleted Successfully"}, status=status.HTTP_200_OK)
        except CustomTask.DoesNotExist:
            return Response({"error": "Post not found."}, status=status.HTTP_404_NOT_FOUND)

class CustomTaskUpdateView(APIView):
    permission_classes = [permissions.AllowAny]
    
    def put(self, request, pk):
        data= request.data
        taskid= CustomTask.objects.get(task_id = pk)
        
        serializer = CustomTaskSerializer(instance=taskid, data=data)
        if serializer.is_valid():
            
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)

    
