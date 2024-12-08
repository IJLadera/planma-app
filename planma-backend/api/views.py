from django.db import IntegrityError, transaction
from django.db.models import Q
from rest_framework.response import Response
from rest_framework import generics, permissions, status, viewsets
from .models import *
from .serializers import *
from rest_framework.views import APIView
from rest_framework.decorators import action
from django.shortcuts import get_object_or_404
from datetime import datetime
from django.core.exceptions import ValidationError
from django.utils.timezone import make_aware


#Below is the Events tables

class CustomEventListCreateView(APIView):
    
    permission_classes = [permissions.IsAuthenticated]
    def post(self, request):
        data = request.data
        # data['student_id'] = request.data.student_id
        
        serializer = CustomEventSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response({**serializer.data}, status=status.HTTP_201_CREATED)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)
        # Set the student field to the authenticated user on creation



class EventViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.AllowAny]
    queryset = CustomEvents.objects.all()
    serializer_class = CustomEventSerializer

    @action(detail=False, methods=['post'])
    def add_event(self, request):
        data = request.data

        # Extract data from request
        event_name = data.get('event_name')
        event_desc = data.get('event_desc')
        location = data.get('location')
        scheduled_date = data.get('scheduled_date')
        start_time = data.get('scheduled_start_time')
        end_time = data.get('scheduled_end_time')
        event_type = data.get('event_type')
        student_id = request.user.student_id  # Authenticated user

        # print(f"Authenticated User: {request.user}")
        # print(f"Student ID: {student_id}")

        # Validate input
        if not all([event_name, event_desc, location, scheduled_date, start_time, end_time, event_type]):
            return Response({'error': 'All fields are required except student_id.'}, status=status.HTTP_400_BAD_REQUEST)


        try:
            # Fetch the CustomUser instance
            student = CustomUser.objects.get(student_id=student_id)

            # Check for conflicting task schedule
            duplicate = CustomEvents.objects.filter(
                Q(scheduled_date=scheduled_date) &
                Q(scheduled_start_time=start_time) &
                Q(scheduled_end_time=end_time) &
                Q(student_id=student)
            ).exists()

            if duplicate:
                return Response(
                    {'error': 'Conflicting event schedule detected.'},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Create Events
            event = CustomEvents.objects.create(
                event_name=event_name,
                event_desc=event_desc,
                location=location,
                scheduled_date=scheduled_date,
                scheduled_start_time=start_time,
                scheduled_end_time=end_time,
                event_type=event_type,
                student_id=student,
            )

            # Serialize and return the created data
            serializer = self.get_serializer(event)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        except CustomUser.DoesNotExist:
            return Response(
                {'error': 'Authenticated user not found in CustomUser table.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        except ValidationError as ve:
            return Response({'error': str(ve)}, status=status.HTTP_400_BAD_REQUEST)
        except IntegrityError:
            return Response(
                {'error': 'A database integrity error occurred.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            return Response(
                {'error': f'An error occurred: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


    def update(self, request, *args, **kwargs):
        instance = self.get_object()
        data = request.data

        # Update fields for the task
        event_name = data.get('event_name')
        event_desc = data.get('event_desc')
        location = data.get('location')
        scheduled_date = data.get('scheduled_date')
        start_time = data.get('scheduled_start_time')
        end_time = data.get('scheduled_end_time')
        event_type = data.get('event_type')

        if not all([event_name, event_desc, location, scheduled_date, start_time, end_time, event_type]):
            return Response({'error': 'All fields are required except student_id.'}, status=status.HTTP_400_BAD_REQUEST)


        try:

            # Check for conflicting task schedule (excluding current task)
            duplicate = CustomEvents.objects.filter(
                Q(scheduled_date=scheduled_date) &
                Q(scheduled_start_time=start_time) &
                Q(scheduled_end_time=end_time) &
                Q(student_id=instance.student_id) &
                ~Q(event_id=instance.event_id)  # Exclude the current event from duplicate check
            ).exists()

            if duplicate:
                return Response(
                    {'error': 'Conflicting task schedule detected.'},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Update the task instance
            instance.event_name = event_name
            instance.event_desc = event_desc
            instance.location = location
            instance.scheduled_date = scheduled_date
            instance.scheduled_start_time = start_time
            instance.scheduled_end_time = end_time
            instance.event_type = event_type
            instance.save()

            # Serialize and return the updated data
            serializer = self.get_serializer(instance)
            return Response(serializer.data, status=status.HTTP_200_OK)

        except ValidationError as ve:
            return Response({'error': str(ve)}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response(
                {'error': f'An error occurred: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

        
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
    
    permission_classes = [permissions.IsAuthenticated]
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


# Goals

class GoalsListCreateView(APIView):
    
    permission_classes = [permissions.AllowAny]
    def post(self, request):
        data = request.data
        serializer = GoalsSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response({**serializer.data}, status=status.HTTP_200_OK)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)
        # Set the student_id field to the authenticated user on creation
        
class GoalsDetailView(APIView):
   
    permission_classes = [permissions.AllowAny]

    def get(self,request,pk):
        
        user = CustomUser.objects.get(student_id = pk)
        goals = Goals.objects.filter(student_id = user)
        serializer = GoalsSerializer(goals, many = True)
        
        return Response(serializer.data)
    
class GoalsDeleteView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def delete(self,request,pk):
        try:
            
            deletegoals = Goals.objects.get(goal_id = pk)
            
            deletegoals.delete()
            
            return Response({"message : Post deleted Successfully"}, status=status.HTTP_200_OK)
        except Goals.DoesNotExist:
            return Response({"error": "Post not found."}, status=status.HTTP_404_NOT_FOUND)

class GoalsUpdateView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def put(self, request, pk):
        data= request.data
        goalid= Goals.objects.get(goal_id = pk)
        
        serializer = GoalsSerializer(instance=goalid, data=data)
        if serializer.is_valid():
            
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)
# OLANGO VIEWS
# Class Schedule & Subject
class ClassScheduleViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.AllowAny]
    queryset = CustomClassSchedule.objects.all()
    serializer_class = CustomClassScheduleSerializer

    @action(detail=False, methods=['post'])
    def add_schedule(self, request):
        data = request.data

        # Extract data from request
        subject_code = data.get('subject_code')
        subject_title = data.get('subject_title')
        semester_id = data.get('semester_id')
        day_of_week = data.get('day_of_week')
        start_time = data.get('scheduled_start_time')
        end_time = data.get('scheduled_end_time')
        room = data.get('room')
        student_id = request.user.student_id  # Authenticated user

        # Validate input
        if not all([subject_code, subject_title, semester_id, day_of_week, start_time, end_time, room]):
            return Response({'error': 'All fields are required except student_id.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Check for duplicate schedule
            duplicate = CustomClassSchedule.objects.filter(
                Q(day_of_week=day_of_week) &
                Q(scheduled_start_time=start_time) &
                Q(scheduled_end_time=end_time) &
                Q(room=room) &
                Q(student_id=student_id) 
            ).exists()

            if duplicate:
                return Response(
                    {'error': 'Duplicate schedule entry detected.'},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Create or get the Subject
            subject, created = CustomSubject.objects.get_or_create(
                subject_code=subject_code,
                defaults={
                    'subject_title': subject_title,
                    'semester_id_id': semester_id,
                    'student_id_id': student_id,
                }
            )

            # Create the Class Schedule
            class_schedule = CustomClassSchedule.objects.create(
                subject_code=subject,
                day_of_week=day_of_week,
                scheduled_start_time=start_time,
                scheduled_end_time=end_time,
                room=room,
                student_id_id=student_id,
            )

            # Serialize and return the created data
            serializer = self.get_serializer(class_schedule)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        except IntegrityError:
            return Response(
                {'error': 'A database integrity error occurred.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            return Response(
                {'error': f'An error occurred: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def get_queryset(self):
        queryset = super().get_queryset()
        semester_id = self.request.query_params.get('semester_id')
        if semester_id:
            # Validate if the semester_id exists
            get_object_or_404(CustomSemester, pk=semester_id)
            queryset = queryset.filter(subject_code__semester_id=semester_id)
        return queryset
    
    def update(self, request, *args, **kwargs):
        instance = self.get_object()
        data = request.data

        # Update fields for the class schedule
        subject_code = data.get('subject_code')
        subject_title = data.get('subject_title')
        semester_id = data.get('semester_id')
        day_of_week = data.get('day_of_week')
        start_time = data.get('scheduled_start_time')
        end_time = data.get('scheduled_end_time')
        room = data.get('room')

        # Validate input
        if not all([subject_code, subject_title, semester_id, day_of_week, start_time, end_time, room]):
            return Response({'error': 'All fields are required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Check if the subject needs updating or creation
            subject, created = CustomSubject.objects.get_or_create(
                subject_code=subject_code,
                defaults={
                    'subject_title': subject_title,
                    'semester_id_id': semester_id,
                    'student_id_id': request.user.student_id,
                },
            )
            if not created:  # If the subject already exists, update its details
                subject.subject_title = subject_title
                subject.semester_id_id = semester_id
                subject.save()

            # Update the class schedule instance
            instance.subject_code = subject
            instance.day_of_week = day_of_week
            instance.scheduled_start_time = start_time
            instance.scheduled_end_time = end_time
            instance.room = room
            instance.save()

            serializer = self.get_serializer(instance)
            return Response(serializer.data, status=status.HTTP_200_OK)

        except Exception as e:
            return Response(
                {'error': f'An error occurred: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        subject_code = instance.subject_code

        with transaction.atomic():
            self.perform_destroy(instance)
            if not CustomClassSchedule.objects.filter(subject_code=subject_code).exists():
                subject_code.delete()

        return Response(status=status.HTTP_204_NO_CONTENT)

# Subject
class SubjectViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.AllowAny]
    queryset = CustomSubject.objects.all()
    serializer_class = CustomSubjectSerializer

    @action(detail=False, methods=['get'], url_path='(?P<subject_code>[^/.]+)')
    def get_subject_by_code(self, request, subject_code):
        try:
            subject = CustomSubject.objects.get(subject_code=subject_code)
            serializer = self.get_serializer(subject)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except CustomSubject.DoesNotExist:
            return Response({'error': 'Subject not found'}, status=status.HTTP_404_NOT_FOUND)

    def get_queryset(self):
        semester_id = self.request.query_params.get('semester_id', None)
        subject_code = self.kwargs.get('subject_code')

        if semester_id:
            return CustomSubject.objects.filter(semester_id=semester_id)  # Filter by semester_id

        if subject_code:
            return CustomSubject.objects.filter(subject_code=subject_code)  # Filter by subject_code
        
        return CustomSubject.objects.all()

# Semester
class SemesterViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.AllowAny]
    queryset = CustomSemester.objects.all()
    serializer_class = CustomSemesterSerializer

    # def get(self, request):
    #     semesters = CustomSemester.objects.all()
    #     serializer = CustomSemesterSerializer(semesters, many=True)
    #     return Response(serializer.data)

    @action(detail=False, methods=['post'])
    def post(self, request):
        serializer = CustomSemesterSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# Task
class TaskViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.AllowAny]
    queryset = CustomTask.objects.all()
    serializer_class = CustomTaskSerializer

    @action(detail=False, methods=['post'])
    def add_task(self, request):
        data = request.data

        # Extract data from request
        task_name = data.get('task_name')
        task_desc = data.get('task_desc')
        scheduled_date = data.get('scheduled_date')
        start_time = data.get('scheduled_start_time')
        end_time = data.get('scheduled_end_time')
        deadline_str = data.get('deadline')
        subject_code = data.get('subject_code')
        student_id = request.user.student_id  # Authenticated user

        # print(f"Authenticated User: {request.user}")
        # print(f"Student ID: {student_id}")

        # Validate input
        if not all([task_name, task_desc, scheduled_date, start_time, end_time, deadline_str, subject_code]):
            return Response({'error': 'All fields are required except student_id.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Convert deadline to timezone-aware datetime
            deadline = make_aware(datetime.strptime(deadline_str, "%Y-%m-%dT%H:%M"))
        except ValueError:
            return Response(
                {'error': 'Invalid deadline format. Use "YYYY-MM-DDTHH:MM".'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            # Fetch or raise error if subject doesn't exist
            subject = get_object_or_404(CustomSubject, subject_code=subject_code)

            # Fetch the CustomUser instance
            student = CustomUser.objects.get(student_id=student_id)

            # Check for conflicting task schedule
            duplicate = CustomTask.objects.filter(
                Q(scheduled_date=scheduled_date) &
                Q(scheduled_start_time=start_time) &
                Q(scheduled_end_time=end_time) &
                Q(student_id=student)
            ).exists()

            if duplicate:
                return Response(
                    {'error': 'Conflicting task schedule detected.'},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Create Task
            task = CustomTask.objects.create(
                task_name=task_name,
                task_desc=task_desc,
                scheduled_date=scheduled_date,
                scheduled_start_time=start_time,
                scheduled_end_time=end_time,
                deadline=deadline,
                status='Pending',
                subject_code=subject,
                student_id=student,
            )

            # Serialize and return the created data
            serializer = self.get_serializer(task)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        except CustomUser.DoesNotExist:
            return Response(
                {'error': 'Authenticated user not found in CustomUser table.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        except ValidationError as ve:
            return Response({'error': str(ve)}, status=status.HTTP_400_BAD_REQUEST)
        except IntegrityError:
            return Response(
                {'error': 'A database integrity error occurred.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            return Response(
                {'error': f'An error occurred: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


    def update(self, request, *args, **kwargs):
        instance = self.get_object()
        data = request.data

        # Update fields for the task
        task_name = data.get('task_name')
        task_desc = data.get('task_desc')
        scheduled_date = data.get('scheduled_date')
        start_time = data.get('scheduled_start_time')
        end_time = data.get('scheduled_end_time')
        deadline_str = data.get('deadline')
        subject_code = data.get('subject_code')

        # Validate input
        if not all([task_name, task_desc, scheduled_date, start_time, end_time, deadline_str, subject_code]):
            return Response({'error': 'All fields are required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Convert deadline to timezone-aware datetime
            deadline = make_aware(datetime.strptime(deadline_str, "%Y-%m-%dT%H:%M"))
        except ValueError:
            return Response(
                {'error': 'Invalid deadline format. Use "YYYY-MM-DDTHH:MM".'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            # Fetch or raise error if subject doesn't exist
            subject = get_object_or_404(CustomSubject, subject_code=subject_code)

            # Check for conflicting task schedule (excluding current task)
            duplicate = CustomTask.objects.filter(
                Q(scheduled_date=scheduled_date) &
                Q(scheduled_start_time=start_time) &
                Q(scheduled_end_time=end_time) &
                Q(student_id=instance.student_id) &
                ~Q(task_id=instance.task_id)  # Exclude the current task from duplicate check
            ).exists()

            if duplicate:
                return Response(
                    {'error': 'Conflicting task schedule detected.'},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Update the task instance
            instance.task_name = task_name
            instance.task_desc = task_desc
            instance.scheduled_date = scheduled_date
            instance.scheduled_start_time = start_time
            instance.scheduled_end_time = end_time
            instance.deadline = deadline
            instance.subject_code = subject
            instance.save()

            # Serialize and return the updated data
            serializer = self.get_serializer(instance)
            return Response(serializer.data, status=status.HTTP_200_OK)

        except ValidationError as ve:
            return Response({'error': str(ve)}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response(
                {'error': f'An error occurred: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

#Might delete
# Goal Progress

class GoalProgressListCreateView(APIView):
    
    permission_classes = [permissions.AllowAny]
    def post(self, request):
        data = request.data
        serializer = GoalProgressSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response({**serializer.data}, status=status.HTTP_200_OK)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)
        # Set the student_id field to the authenticated user on creation
        
class GoalProgressDetailView(APIView):
   
    permission_classes = [permissions.AllowAny]

    def get(self,request,pk):
        
        goal = Goals.objects.get(goal_id = pk)
        goalprog = GoalProgress.objects.filter(student_id = goal)
        serializer = GoalProgressSerializer(goalprog, many = True)
        
        return Response(serializer.data)
    
class GoalProgressDeleteView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def delete(self,request,pk):
        try:
            
            deletegoals = GoalProgress.objects.get(goalprogress_id = pk)
            
            deletegoals.delete()
            
            return Response({"message : Post deleted Successfully"}, status=status.HTTP_200_OK)
        except GoalProgress.DoesNotExist:
            return Response({"error": "Post not found."}, status=status.HTTP_404_NOT_FOUND)

class GoalProgressUpdateView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def put(self, request, pk):
        data= request.data
        goalid= GoalProgress.objects.get(goalprogress_id = pk)
        
        serializer = GoalProgressSerializer(instance=goalid, data=data)
        if serializer.is_valid():
            
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)

# Goal Progress

class GoalScheduleListCreateView(APIView):
    
    permission_classes = [permissions.AllowAny]
    def post(self, request):
        data = request.data
        serializer = GoalScheduleSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response({**serializer.data}, status=status.HTTP_200_OK)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)
        # Set the student_id field to the authenticated user on creation
        
class GoalScheduleDetailView(APIView):
   
    permission_classes = [permissions.AllowAny]

    def get(self,request,pk):
        
        goal = Goals.objects.get(goal_id = pk)
        goalsched = GoalSchedule.objects.filter(student_id = goal)
        serializer = GoalProgressSerializer(goalsched, many = True)
        
        return Response(serializer.data)
    
class GoalScheduleDeleteView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def delete(self,request,pk):
        try:
            
            deletegoals = GoalSchedule.objects.get(goalschedule_id = pk)
            
            deletegoals.delete()
            
            return Response({"message : Post deleted Successfully"}, status=status.HTTP_200_OK)
        except GoalProgress.DoesNotExist:
            return Response({"error": "Post not found."}, status=status.HTTP_404_NOT_FOUND)

class GoalScheduleUpdateView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def put(self, request, pk):
        data= request.data
        goalid= GoalSchedule.objects.get(goalprogress_id = pk)
        
        serializer = GoalScheduleSerializer(instance=goalid, data=data)
        if serializer.is_valid():
            
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)

#Sleep

    permission_classes = [permissions.AllowAny]
    
    def put(self, request, pk):
        data= request.data
        repid= SleepLog.objects.get(report_id = pk)
        serializer = SleepLogSerializer(instance=repid, data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)
class SleepLogListCreateView(APIView):
    
    permission_classes = [permissions.AllowAny]
    def post(self, request):
        data = request.data
        serializer = SleepLogSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response({**serializer.data}, status=status.HTTP_200_OK)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)
        # Set the student_id field to the authenticated user on creation
        
class SleepLogDetailView(APIView):
   
    permission_classes = [permissions.AllowAny]

    def get(self,request,pk):
        
        user = CustomUser.objects.get(student_id = pk)
        sleep = CustomTask.objects.filter(student_id = user)
        serializer = CustomTaskSerializer(sleep, many = True)

        return Response(serializer.data)
    
class SleepLogDeleteView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def delete(self,request,pk):
        try:
            
            deletegoals = SleepLog.objects.get(goalschedule_id = pk)
            
            deletegoals.delete()
            
            return Response({"message : Post deleted Successfully"}, status=status.HTTP_200_OK)
        except SleepLog.DoesNotExist:
            return Response({"error": "Post not found."}, status=status.HTTP_404_NOT_FOUND)

class SleepLogUpdateView(APIView):

    permission_classes = [permissions.AllowAny]
    
    def put(self, request, pk):
        data= request.data
        sleeplog= SleepLog.objects.get(sleep_log_id = pk)
        
        serializer = GoalScheduleSerializer(instance=sleeplog, data=data)
        if serializer.is_valid():
            
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)

