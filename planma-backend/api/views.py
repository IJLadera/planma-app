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

#Below is the Events tables

class CustomEventListCreateView(APIView):
    
    permission_classes = [permissions.AllowAny]
    def post(self, request):
        data = request.data
        serializer = CustomEventSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response({**serializer.data}, status=status.HTTP_200_OK)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)
        # Set the student field to the authenticated user on creation
        
class CustomEventDetailView(APIView):
   
    permission_classes = [permissions.AllowAny]

    def get(self,request,pk):
        
        user = CustomUser.objects.get(student_id = pk)
        event = CustomEvents.objects.filter(student_id = user)
        serializer = CustomEventSerializer(event, many = True)
        
        return Response(serializer.data)
    
class CustomEventDeleteView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def delete(self,request,pk):
        try:
            
            deleteevent = CustomEvents.objects.get(event_id = pk)
            
            deleteevent.delete()
            
            return Response({"message : Post deleted Successfully"}, status=status.HTTP_200_OK)
        except CustomEvents.DoesNotExist:
            return Response({"error": "Post not found."}, status=status.HTTP_404_NOT_FOUND)

class CustomEventUpdateView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def put(self, request, pk):
        data= request.data
        eventid= CustomEvents.objects.get(event_id = pk)
        
        serializer = CustomTaskSerializer(instance=eventid, data=data)
        if serializer.is_valid():
            
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)
        
#below is the Attended Event Table

class AttendedEventListCreateView(APIView):
    
    permission_classes = [permissions.AllowAny]
    def post(self, request):
        data = request.data
        serializer = AttendedEventSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response({**serializer.data}, status=status.HTTP_200_OK)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)
        # Set the event_id field to the authenticated user on creation
        
class AttendedEventDetailView(APIView):
   
    permission_classes = [permissions.AllowAny]

    def get(self,request,pk):
        
        event = CustomEvents.objects.get(event_id = pk)
        attev = AttendedEvents.objects.filter(event_id = event)
        serializer = AttendedEventSerializer(attev, many = True)
        
        return Response(serializer.data)
    
class AttendedEventDeleteView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def delete(self,request,pk):
        try:
            
            deleteattev = CustomEvents.objects.get(att_events_id = pk)
            
            deleteattev.delete()
            
            return Response({"message : Post deleted Successfully"}, status=status.HTTP_200_OK)
        except CustomEvents.DoesNotExist:
            return Response({"error": "Post not found."}, status=status.HTTP_404_NOT_FOUND)

class AttendedEventUpdateView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def put(self, request, pk):
        data= request.data
        attevid= CustomEvents.objects.get(att_events_id = pk)
        
        serializer = CustomTaskSerializer(instance=attevid, data=data)
        if serializer.is_valid():
            
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)

#below is the activity tables

class CustomActivityListCreateView(APIView):
    
    permission_classes = [permissions.AllowAny]
    def post(self, request):
        data = request.data
        serializer = CustomActivitySerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response({**serializer.data}, status=status.HTTP_200_OK)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)
        # Set the student_id field to the authenticated user on creation
        
class CustomActivityDetailView(APIView):
   
    permission_classes = [permissions.AllowAny]

    def get(self,request,pk):
        
        user = CustomUser.objects.get(student_id = pk)
        act = CustomActivity.objects.filter(student_id = user)
        serializer = CustomActivitySerializer(act, many = True)
        
        return Response(serializer.data)
    
class CustomActivityDeleteView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def delete(self,request,pk):
        try:
            
            deleteact = CustomActivity.objects.get(activity_id = pk)
            
            deleteact.delete()
            
            return Response({"message : Post deleted Successfully"}, status=status.HTTP_200_OK)
        except CustomActivity.DoesNotExist:
            return Response({"error": "Post not found."}, status=status.HTTP_404_NOT_FOUND)

class CustomActivityUpdateView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def put(self, request, pk):
        data= request.data
        actid= CustomActivity.objects.get(activity_id = pk)
        
        serializer = CustomActivitySerializer(instance=actid, data=data)
        if serializer.is_valid():
            
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)

#below is the Activity Log view

class LogActivityListCreateView(APIView):
    
    permission_classes = [permissions.AllowAny]
    def post(self, request):
        data = request.data
        serializer = ActivityLogSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response({**serializer.data}, status=status.HTTP_200_OK)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)
        # Set the student_id field to the authenticated user on creation
        
class LogActivityDetailView(APIView):
   
    permission_classes = [permissions.AllowAny]

    def get(self,request,pk):
        
        act = CustomActivity.objects.get(activity_id = pk)
        actlog = ActivityLog.objects.filter(activity_id = act)
        serializer = CustomActivitySerializer(actlog, many = True)
        
        return Response(serializer.data)
    
class LogActivityDeleteView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def delete(self,request,pk):
        try:
            
            deleteactlog = ActivityLog.objects.get(act_log_id = pk)
            
            deleteactlog.delete()
            
            return Response({"message : Post deleted Successfully"}, status=status.HTTP_200_OK)
        except ActivityLog.DoesNotExist:
            return Response({"error": "Post not found."}, status=status.HTTP_404_NOT_FOUND)

class LogActivityUpdateView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def put(self, request, pk):
        data= request.data
        actlogid= ActivityLog.objects.get(act_log_id = pk)
        
        serializer = ActivityLogSerializer(instance=actlogid, data=data)
        if serializer.is_valid():
            
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)

#User Preferences
class UserPrefListCreateView(APIView):
    
    permission_classes = [permissions.AllowAny]
    def post(self, request):
        data = request.data
        serializer = UserPrefSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response({**serializer.data}, status=status.HTTP_200_OK)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)
        # Set the student_id field to the authenticated user on creation
        
class UserPrefDetailView(APIView):
   
    permission_classes = [permissions.AllowAny]

    def get(self,request,pk):
        
        user = UserPref.objects.get(student_id = pk)
        userpref = CustomUser.objects.filter(student_id = user)
        serializer = UserPrefSerializer(userpref, many = True)
        
        return Response(serializer.data)
    
class UserPrefDeleteView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def delete(self,request,pk):
        try:
            
            deleteuserpref = UserPref.objects.get(pref_id = pk)
            
            deleteuserpref.delete()
            
            return Response({"message : Post deleted Successfully"}, status=status.HTTP_200_OK)
        except UserPref.DoesNotExist:
            return Response({"error": "Post not found."}, status=status.HTTP_404_NOT_FOUND)

class UserPrefUpdateView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def put(self, request, pk):
        data= request.data
        userprefid= UserPref.objects.get(pref_id = pk)
        
        serializer = UserPrefSerializer(instance=userprefid, data=data)
        if serializer.is_valid():
            
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)


# Class

class CustomClassListCreateView(APIView):
    
    permission_classes = [permissions.AllowAny]
    def post(self, request):
        data = request.data
        serializer = CustomClassSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response({**serializer.data}, status=status.HTTP_200_OK)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)
        # Set the student_id field to the authenticated user on creation
        
class CustomClassDetailView(APIView):
   
    permission_classes = [permissions.AllowAny]

    def get(self,request,pk):
        
        user = CustomUser.objects.get(student_id = pk)
        cusclass = CustomClass.objects.filter(student_id = user)
        serializer = UserPrefSerializer(cusclass, many = True)
        
        return Response(serializer.data)
    
class CustomClassDeleteView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def delete(self,request,pk):
        try:
            
            deletecusclass = CustomClass.objects.get(classsched_id = pk)
            
            deletecusclass.delete()
            
            return Response({"message : Post deleted Successfully"}, status=status.HTTP_200_OK)
        except UserPref.DoesNotExist:
            return Response({"error": "Post not found."}, status=status.HTTP_404_NOT_FOUND)

class CustomClassUpdateView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def put(self, request, pk):
        data= request.data
        classid= CustomClass.objects.get(classsched_id = pk)
        
        serializer = CustomClassSerializer(instance=classid, data=data)
        if serializer.is_valid():
            
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)


# Class Excused

class ExcClassListCreateView(APIView):
    
    permission_classes = [permissions.AllowAny]
    def post(self, request):
        data = request.data
        serializer = ExcusedClassSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response({**serializer.data}, status=status.HTTP_200_OK)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)
        # Set the student_id field to the authenticated user on creation
        
class ExcClassDetailView(APIView):
   
    permission_classes = [permissions.AllowAny]

    def get(self,request,pk):
        
        cusclass = CustomClass.objects.get(classsched_id = pk)
        excclass = ExcusedClass.objects.filter(classsched_id = cusclass)
        serializer = ExcusedClassSerializer(excclass, many = True)
        
        return Response(serializer.data)
    
class ExcClassDeleteView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def delete(self,request,pk):
        try:
            
            deleteexcclass = ExcusedClass.objects.get(exc_class_id = pk)
            
            deleteexcclass.delete()
            
            return Response({"message : Post deleted Successfully"}, status=status.HTTP_200_OK)
        except ExcusedClass.DoesNotExist:
            return Response({"error": "Post not found."}, status=status.HTTP_404_NOT_FOUND)

class ExcClassUpdateView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def put(self, request, pk):
        data= request.data
        classid= ExcusedClass.objects.get(exc_class_id = pk)
        
        serializer = ExcusedClassSerializer(instance=classid, data=data)
        if serializer.is_valid():
            
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)


# Class Attended

class AttClassListCreateView(APIView):
    
    permission_classes = [permissions.AllowAny]
    def post(self, request):
        data = request.data
        serializer = AttendedClassSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response({**serializer.data}, status=status.HTTP_200_OK)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)
        # Set the student_id field to the authenticated user on creation
        
class AttClassDetailView(APIView):
   
    permission_classes = [permissions.AllowAny]

    def get(self,request,pk):
        
        cusclass = CustomClass.objects.get(classsched_id = pk)
        attclass = AttendedClass.objects.filter(classsched_id = cusclass)
        serializer = UserPrefSerializer(attclass, many = True)
        
        return Response(serializer.data)
    
class AttClassDeleteView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def delete(self,request,pk):
        try:
            
            deleteattclass = AttendedClass.objects.get(att_class_id = pk)
            
            deleteattclass.delete()
            
            return Response({"message : Post deleted Successfully"}, status=status.HTTP_200_OK)
        except AttendedClass.DoesNotExist:
            return Response({"error": "Post not found."}, status=status.HTTP_404_NOT_FOUND)

class AttClassUpdateView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def put(self, request, pk):
        data= request.data
        classid= AttendedClass.objects.get(att_class_id = pk)
        
        serializer = AttendedClassSerializer(instance=classid, data=data)
        if serializer.is_valid():
            
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)
