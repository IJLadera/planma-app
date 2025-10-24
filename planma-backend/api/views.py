from django.db import IntegrityError, transaction
from django.db.models import Q
from rest_framework.response import Response
from rest_framework import generics, permissions, status, viewsets
from rest_framework.permissions import IsAuthenticated
from .models import *
from .serializers import *
from rest_framework.views import APIView
from djoser.views import UserViewSet
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.decorators import action
from django.shortcuts import get_object_or_404
from datetime import datetime, timedelta, time as dtime
from django.core.exceptions import ValidationError, PermissionDenied
from django.utils.timezone import make_aware, now
from django.http import JsonResponse
from datetime import datetime, timedelta
from api.tasks import send_push_notification

# views.py
# from djoser.views import TokenCreateView
from rest_framework.response import Response
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from api.models import CustomUser
import os
from django.http import JsonResponse
from supabase import create_client, Client
from supabase_storage import upload_profile_picture

class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer

class ActivityViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.AllowAny]
    serializer_class = CustomActivitySerializer

    def get_queryset(self):
        queryset = CustomActivity.objects.filter(student_id=self.request.user)

        # Apply scheduled_date filtering if provided in query params
        start_date = self.request.query_params.get('start_date')
        end_date = self.request.query_params.get('end_date')

        if start_date and end_date:
            queryset = queryset.filter(scheduled_date__range=[start_date, end_date])

        return queryset
    
    @action(detail=False, methods=['get'])
    def pending_activities(self, request):
        # Get activities that are still pending
        activities = CustomActivity.objects.filter(
            student_id=request.user.student_id,
            status='Pending'
        )
        serializer = self.get_serializer(activities, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def completed_activities(self, request):
        # Get activities that have been completed
        activities = CustomActivity.objects.filter(
            student_id=request.user.student_id,
            status='Completed'
        )
        serializer = self.get_serializer(activities, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['post'])
    def add_activity(self, request):
        data = request.data

        # Extract data from request
        activity_name = data.get('activity_name')
        activity_desc = data.get('activity_desc')
        scheduled_date = data.get('scheduled_date')
        start_time = data.get('scheduled_start_time')
        end_time = data.get('scheduled_end_time')
        student_id = request.user.student_id  # Authenticated user

        if activity_desc is not None and isinstance(activity_desc, str) and activity_desc.strip() == '':
            activity_desc = None

        # Validate input
        if not all([activity_name, scheduled_date, start_time, end_time]):
            return Response({'error': 'All fields are required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Fetch the CustomUser instance
            student = CustomUser.objects.get(student_id=student_id)

            # Check for conflicting activity schedule
            duplicate = CustomActivity.objects.filter(
                Q(scheduled_date=scheduled_date) &
                Q(scheduled_start_time=start_time) &
                Q(scheduled_end_time=end_time) &
                Q(student_id=student)
            ).exists()

            if duplicate:
                return Response(
                    {'error': 'Conflicting activity schedule detected.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Check for overlapping schedules
            overlapping_schedules = ScheduleEntry.objects.filter(
                student_id=student,
                scheduled_date=scheduled_date
            ).filter(
                Q(scheduled_start_time__lt=end_time, scheduled_end_time__gt=start_time)
            )

            if overlapping_schedules.exists():
                return Response({'error_type': 'overlap', 'message': 'This time slot is already occupied. Please choose another time.'}, status=status.HTTP_400_BAD_REQUEST)

            # Create Activity
            activity = CustomActivity.objects.create(
                activity_name=activity_name,
                activity_desc=activity_desc or None,
                scheduled_date=scheduled_date,
                scheduled_start_time=start_time,
                scheduled_end_time=end_time,
                status='Pending',
                student_id=student,
            )

            # Create ScheduleEntry
            ScheduleEntry.objects.create(
                category_type='Activity',
                reference_id=activity.activity_id,  # FK reference to the created activity
                student_id=student,
                scheduled_date=scheduled_date,
                scheduled_start_time=start_time,
                scheduled_end_time=end_time
            )
            print(f"ScheduleEntry created successfully!")

            # Serialize and return the created data
            serializer = self.get_serializer(activity)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        except CustomActivity.DoesNotExist:
            return Response(
                {'error': 'Authenticated user not found in CustomActivity table.'},
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

        # Update fields for the activity
        activity_name = data.get('activity_name')
        activity_desc = data.get('activity_desc')
        scheduled_date = data.get('scheduled_date')
        start_time = data.get('scheduled_start_time')
        end_time = data.get('scheduled_end_time')

        if activity_desc is not None and isinstance(activity_desc, str) and activity_desc.strip() == '':
            activity_desc = None

        # Validate input
        if not all([activity_name, scheduled_date, start_time, end_time]):
            return Response({'error': 'All fields are required.'}, status=status.HTTP_400_BAD_REQUEST)

        # Parse scheduled_date, start_time, end_time
        try:
            if isinstance(scheduled_date, str):
                scheduled_date = datetime.fromisoformat(scheduled_date).date()

            if isinstance(start_time, str):
                start_time = dtime.fromisoformat(start_time)

            if isinstance(end_time, str):
                end_time = dtime.fromisoformat(end_time)
        except ValueError as ve:
            return Response(
                {'error': f'Invalid date/time format: {ve}'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            # Check for conflicting activity schedule (excluding current activity)
            duplicate = CustomActivity.objects.filter(
                Q(scheduled_date=scheduled_date) &
                Q(scheduled_start_time=start_time) &
                Q(scheduled_end_time=end_time) &
                Q(student_id=instance.student_id) &
                ~Q(activity_id=instance.activity_id)  # Exclude the current activity from duplicate check
            ).exists()

            if duplicate:
                return Response(
                    {'error': 'Conflicting activity schedule detected.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Check for overlapping schedules
            overlapping_schedules = ScheduleEntry.objects.filter(
                student_id=instance.student_id,
                scheduled_date=scheduled_date
            ).filter(
                Q(scheduled_start_time__lt=end_time, scheduled_end_time__gt=start_time)
            ).exclude(
                Q(category_type='Activity') & Q(reference_id=instance.activity_id)  # Exclude the current activity entry
            )

            if overlapping_schedules.exists():
                return Response({'error_type': 'overlap', 'message': 'This time slot is already occupied. Please choose another time.'}, status=status.HTTP_400_BAD_REQUEST)

            # Reset reminder_sent if event is moved to a future datetime
            old_dt = timezone.make_aware(datetime.combine(instance.scheduled_date, instance.scheduled_start_time))
            new_dt = timezone.make_aware(datetime.combine(scheduled_date, start_time))
            if instance.reminder_sent and new_dt > old_dt:
                instance.reminder_sent = False

            # Update the activity instance
            instance.activity_name = activity_name
            instance.activity_desc = activity_desc
            instance.scheduled_date = scheduled_date
            instance.scheduled_start_time = start_time
            instance.scheduled_end_time = end_time
            instance.save()

            # Update the related ScheduleEntry
            schedule_entry = ScheduleEntry.objects.filter(
                category_type='Activity',
                reference_id=instance.activity_id
            ).first()

            if schedule_entry:
                schedule_entry.scheduled_date = scheduled_date
                schedule_entry.scheduled_start_time = start_time
                schedule_entry.scheduled_end_time = end_time
                schedule_entry.save()

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
        
# Activity Time Log
class ActivityTimeLogViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.AllowAny]
    serializer_class = ActivityLogSerializer

    def get_queryset(self):
        # Filter logged activities based on the logged-in user
        queryset = ActivityTimeLog.objects.filter(activity_id__student_id=self.request.user)

        # Apply date_logged filtering if provided in query params
        start_date = self.request.query_params.get('start_date')
        end_date = self.request.query_params.get('end_date')

        if start_date and end_date:
            queryset = queryset.filter(date_logged__range=[start_date, end_date])

        return queryset
    
    @action(detail=False, methods=['post'])
    def log_time(self, request):
        data = request.data

        activity_id = data.get('activity_id')
        start_time = data.get('start_time')
        end_time = data.get('end_time')
        duration = data.get('duration')
        date_logged = data.get('date_logged')

        # Validate input
        if not all([activity_id, start_time, end_time, duration, date_logged]):
            return Response(
                {'error': 'Missing fields.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            # Validate the activity exists
            activity = CustomActivity.objects.get(activity_id=activity_id, student_id=request.user)

            # Check if a time log already exists for the same activity and date
            existing_log = ActivityTimeLog.objects.filter(
                activity_id=activity,
                date_logged=date_logged
            ).first()

            if existing_log:
                return Response(
                    {'error': 'A time log for this activity and date already exists.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Convert duration from string to timedelta
            hours, minutes, seconds = map(int, duration.split(':'))
            duration_timedelta = timedelta(hours=hours, minutes=minutes, seconds=seconds)

            # Create the time log
            log = ActivityTimeLog.objects.create(
                activity_id=activity,
                start_time=start_time,
                end_time=end_time,
                duration=duration_timedelta,
                date_logged=date_logged
            )

            # Update the activity status to "Completed"
            activity.status = "Completed"
            activity.save()

            # Serialize and return the created time log
            serializer = self.get_serializer(log)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        except CustomActivity.DoesNotExist:
            return Response(
                {'error': 'Activity not found or not associated with the logged-in user.'},
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            return Response(
                {'error': f'An error occurred: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

class EventViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.AllowAny]
    serializer_class = CustomEventSerializer

    def get_queryset(self):
        # Filter events based on the logged-in user
        return CustomEvents.objects.filter(student_id=self.request.user)
    
    @action(detail=False, methods=['get'])
    def upcoming_events(self, request):
        # Get events that are today or in the future
        events = CustomEvents.objects.filter(
            student_id=request.user.student_id,
            scheduled_date__gte=now().date()
        )
        serializer = self.get_serializer(events, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def past_events(self, request):
        # Get events that are in the past
        events = CustomEvents.objects.filter(
            student_id=request.user.student_id,
            scheduled_date__lt=now().date()
        )
        serializer = self.get_serializer(events, many=True)
        return Response(serializer.data)

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

        if event_desc is not None and isinstance(event_desc, str) and event_desc.strip() == '':
            event_desc = None

        # Validate input
        if not all([event_name, location, scheduled_date, start_time, end_time, event_type]):
            return Response({'error': 'All fields are required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Fetch the CustomUser instance
            student = CustomUser.objects.get(student_id=student_id)

            # Check for duplicate event schedule
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
            
            # Check for overlapping schedules
            overlapping_schedules = ScheduleEntry.objects.filter(
                student_id=student,
                scheduled_date=scheduled_date
            ).filter(
                Q(scheduled_start_time__lt=end_time, scheduled_end_time__gt=start_time)
            )

            if overlapping_schedules.exists():
                return Response({'error_type': 'overlap', 'message': 'This time slot is already occupied. Please choose another time.'}, status=status.HTTP_400_BAD_REQUEST)

            # Create Events
            event = CustomEvents.objects.create(
                event_name=event_name,
                event_desc=event_desc or None,
                location=location,
                scheduled_date=scheduled_date,
                scheduled_start_time=start_time,
                scheduled_end_time=end_time,
                event_type=event_type,
                student_id=student,
            )

            # Create ScheduleEntry
            ScheduleEntry.objects.create(
                category_type='Event',
                reference_id=event.event_id,  # FK reference to the created event
                student_id=student,
                scheduled_date=scheduled_date,
                scheduled_start_time=start_time,
                scheduled_end_time=end_time
            )
            print(f"ScheduleEntry created successfully!")

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

        if event_desc is not None and isinstance(event_desc, str) and event_desc.strip() == '':
            event_desc = None

        if not all([event_name, location, scheduled_date, start_time, end_time, event_type]):
            return Response({'error': 'All fields are required.'}, status=status.HTTP_400_BAD_REQUEST)

        # Parse scheduled_date, start_time, end_time
        try:
            if isinstance(scheduled_date, str):
                scheduled_date = datetime.fromisoformat(scheduled_date).date()

            if isinstance(start_time, str):
                start_time = dtime.fromisoformat(start_time)

            if isinstance(end_time, str):
                end_time = dtime.fromisoformat(end_time)
        except ValueError as ve:
            return Response(
                {'error': f'Invalid date/time format: {ve}'},
                status=status.HTTP_400_BAD_REQUEST
            )

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
            
            # Check for overlapping schedules
            overlapping_schedules = ScheduleEntry.objects.filter(
                student_id=instance.student_id,
                scheduled_date=scheduled_date
            ).filter(
                Q(scheduled_start_time__lt=end_time, scheduled_end_time__gt=start_time)
            ).exclude(
                Q(category_type='Event') & Q(reference_id=instance.event_id)  # Exclude the current event entry
            )

            if overlapping_schedules.exists():
                return Response({'error_type': 'overlap', 'message': 'This time slot is already occupied. Please choose another time.'}, status=status.HTTP_400_BAD_REQUEST)

            # Reset reminder_sent if event is moved to a future datetime
            old_dt = timezone.make_aware(datetime.combine(instance.scheduled_date, instance.scheduled_start_time))
            new_dt = timezone.make_aware(datetime.combine(scheduled_date, start_time))
            if instance.reminder_sent and new_dt > old_dt:
                instance.reminder_sent = False

            # Update the task instance
            instance.event_name = event_name
            instance.event_desc = event_desc
            instance.location = location
            instance.scheduled_date = scheduled_date
            instance.scheduled_start_time = start_time
            instance.scheduled_end_time = end_time
            instance.event_type = event_type
            instance.save()

            # Update the related ScheduleEntry
            schedule_entry = ScheduleEntry.objects.filter(
                category_type='Event',
                reference_id=instance.event_id
            ).first()

            if schedule_entry:
                schedule_entry.scheduled_date = scheduled_date
                schedule_entry.scheduled_start_time = start_time
                schedule_entry.scheduled_end_time = end_time
                schedule_entry.save()

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

class AttendedEventViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.AllowAny]
    serializer_class = AttendedEventSerializer

    def get_queryset(self):
        # Filter attended events based on the logged-in user
        queryset = AttendedEvents.objects.filter(event_id__student_id=self.request.user)

        # Apply date filtering if provided in query params
        start_date = self.request.query_params.get('start_date')
        end_date = self.request.query_params.get('end_date')

        if start_date and end_date:
            queryset = queryset.filter(date__range=[start_date, end_date])

        return queryset
    
    @action(detail=False, methods=['post'])
    def mark_attendance(self, request):
        data = request.data

        event_id = data.get('event_id')
        date = data.get('date')
        has_attended = data.get('has_attended', False)

        # Validate input
        if not all([event_id, date]):
            return Response(
                {'error': 'event_id and date are required.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            # Validate the event exists
            event = CustomEvents.objects.get(event_id=event_id, student_id=request.user)

            # Check if attendance already exists for the event
            attendance, created = AttendedEvents.objects.get_or_create(
                event_id=event,
                date=date,
                defaults={'has_attended': has_attended}
            )

            if not created:
                # Update the existing attendance record
                attendance.has_attended = has_attended
                attendance.save()
                return Response(
                    {'message': 'Attendance updated successfully.'},
                    status=status.HTTP_200_OK
                )


            # Serialize and return the new attendance
            serializer = self.get_serializer(attendance)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        except CustomEvents.DoesNotExist:
            return Response(
                {'error': 'Event not found or not associated with the logged-in user.'},
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            return Response(
                {'error': f'An error occurred: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
        
    def update(self, request, *args, **kwargs):
        instance = self.get_object()
        data = request.data

        has_attended = data.get('has_attended', None)
        if has_attended is None:
            return Response(
                {'error': 'has_attended field is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            # Update the attendance status
            instance.has_attended = has_attended
            instance.save()

            # Serialize and return the updated data
            serializer = self.get_serializer(instance)
            return Response(serializer.data, status=status.HTTP_200_OK)

        except Exception as e:
            return Response(
                {'error': f'An error occurred: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

#User Preferences
class UserPreferenceView(viewsets.ModelViewSet):
    serializer_class = UserPrefSerializer  
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return UserPref.objects.filter(student_id=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(student_id=self.request.user)

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)
    
    def update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', False)
        instance = self.get_object()

        # Ensure the logged-in user is the owner of the preference
        if instance.student_id != request.user:
            return Response(
                {"detail": "You do not have permission to edit this preference."},
                status=status.HTTP_403_FORBIDDEN
            )

        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)
        return Response(serializer.data)

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()

        # Ensure the logged-in user is the owner of the preference
        if instance.student_id != request.user:
            return Response(
                {"detail": "You do not have permission to delete this preference."},
                status=status.HTTP_403_FORBIDDEN
            )

        self.perform_destroy(instance)
        return Response(
            {"detail": "Preference deleted successfully."}, 
            status=status.HTTP_204_NO_CONTENT
        )

# User/Student
class CustomUserViewSet(UserViewSet):
    def create(self, request, *args, **kwargs):
        response = super().create(request, *args, **kwargs)
        if response.status_code == 201:  # Account successfully created
            user = self.get_user_from_request(request.data)  # Custom method
            refresh = RefreshToken.for_user(user)  # Generate tokens
            response.data['refresh'] = str(refresh)
            response.data['access'] = str(refresh.access_token)
        return response
    def upload_profile_picture(file, filename):
        SUPABASE_URL = os.getenv("SUPABASE_URL")
        SUPABASE_KEY = os.getenv("SUPABASE_KEY")
        SUPABASE_BUCKET = os.getenv("SUPABASE_BUCKET")

        supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

        file_path = f"{filename}"  # Just the filename, not the bucket again
        supabase.storage.from_(SUPABASE_BUCKET).upload(file_path, file, {"upsert": True})

        # ✅ Proper Supabase public URL
        public_url = f"{SUPABASE_URL}/storage/v1/object/public/{SUPABASE_BUCKET}/{file_path}"
        return public_url

    def get_user_from_request(self, data):  
        from django.contrib.auth import get_user_model
        User = get_user_model()
        return User.objects.get(email=data.get("email"))
    
    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def me(self, request):
        """Custom override for /users/me/ to include profile_picture"""
        serializer = CustomUserSerializer(request.user, context={"request": request})
        return Response(serializer.data)
    
    @action(detail=False, methods=['put'], permission_classes=[IsAuthenticated])
    def update_profile(self, request):
        user = request.user
        serializer = CustomUserSerializer(user, data=request.data, partial=True)
        if serializer.is_valid():
            if 'profile_picture' in request.FILES:
                file = request.FILES['profile_picture']
                filename = f"profile_{user.pk}.jpg"

                # ✅ Upload to Supabase Storage
                try:
                    uploaded_url = self.upload_profile_picture(file, filename)
                    user.profile_picture = uploaded_url  # Save Supabase public URL

                except Exception as e:
                    return Response(
                        {"error": f"Failed to upload to Supabase: {str(e)}"},
                        status=status.HTTP_500_INTERNAL_SERVER_ERROR
                    )

            serializer.save()
            return Response({"image_url": user.profile_picture}, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


    
# Class Schedule & Subject
class ClassScheduleViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.AllowAny]
    serializer_class = CustomClassScheduleSerializer

    def get_queryset(self):   
        # Fetch schedules tied to the current user's student_id
        queryset = CustomClassSchedule.objects.filter(student_id=self.request.user.student_id)
    
        # Optionally filter by semester_id if provided
        semester_id = self.request.query_params.get('semester_id')
        if semester_id:
            # Validate semester_id before filtering
            get_object_or_404(CustomSemester, pk=semester_id)
            queryset = queryset.filter(subject__semester_id=semester_id)
    
        return queryset

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
        
        # Day of week mapping (Python: Monday=0, Django __week_day: Sunday=1)
        weekday_map = {
            'Monday': 0,
            'Tuesday': 1,
            'Wednesday': 2,
            'Thursday': 3,
            'Friday': 4,
            'Saturday': 5,
            'Sunday': 6
        }

        if day_of_week not in weekday_map:
            return Response({'error': 'Invalid day_of_week provided.'}, status=status.HTTP_400_BAD_REQUEST)

        day_of_week_int = weekday_map[day_of_week]

        try:
            # Fetch semester to get the start and end dates
            semester = get_object_or_404(CustomSemester, pk=semester_id)
            start_date = semester.sem_start_date
            end_date = semester.sem_end_date

            # Fetch the CustomUser instance
            student = CustomUser.objects.get(student_id=student_id)

            # Fetch or create subject uniquely for this user
            subject, created = CustomSubject.objects.get_or_create(
                subject_code=subject_code,
                student_id_id=student_id,
                semester_id_id=semester_id,
                defaults={'subject_title': subject_title}
            )

            # Check for duplicate schedule
            duplicate = CustomClassSchedule.objects.filter(
                Q(subject=subject) &
                Q(day_of_week=day_of_week) &
                Q(scheduled_start_time=start_time) &
                Q(scheduled_end_time=end_time) &
                Q(student_id=student_id)
            ).exists()

            if duplicate:
                return Response(
                    {'error': 'Duplicate schedule entry detected.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Check for overlaps on that weekday across all weeks
            # First, get all dates in semester matching day_of_week
            current_date = start_date
            conflict_found = False
            conflicting_date = None

            while current_date <= end_date:
                if current_date.weekday() == day_of_week_int:
                    overlapping = ScheduleEntry.objects.filter(
                        student_id=student,
                        scheduled_date=current_date,
                        scheduled_start_time__lt=end_time,
                        scheduled_end_time__gt=start_time
                    )
                    if overlapping.exists():
                        conflict_found = True
                        conflicting_date = current_date
                        break
                current_date += timedelta(days=1)

            if conflict_found:
                return Response({
                    'error_type': 'overlap',
                    'message': f'Conflict on {conflicting_date.strftime("%Y-%m-%d")}. Please choose a different time or day.'
                }, status=status.HTTP_400_BAD_REQUEST)

            # Create the Class Schedule
            class_schedule = CustomClassSchedule.objects.create(
                subject=subject,
                day_of_week=day_of_week,
                scheduled_start_time=start_time,
                scheduled_end_time=end_time,
                room=room,
                student_id_id=student_id,
            )

            # Dynamically Create ScheduleEntry for Each Week of the Semester
            current_date = start_date
            while current_date <= end_date:
                if current_date.weekday() == day_of_week_int:
                    ScheduleEntry.objects.create(
                        category_type='Class',
                        reference_id=class_schedule.classsched_id,
                        student_id=student,
                        scheduled_date=current_date,
                        scheduled_start_time=start_time,
                        scheduled_end_time=end_time
                    )
                current_date += timedelta(days=1)

            print(f"ScheduleEntries created successfully for class schedule!")

            # Serialize and return the created data
            serializer = self.get_serializer(class_schedule)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        except IntegrityError as e:
            return Response(
                {'error': 'Database integrity error: ' + str(e)}, 
                status=status.HTTP_400_BAD_REQUEST)
        
        except Exception as e:
            return Response(
                {'error': f'An error occurred: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def update(self, request, *args, **kwargs):
        instance = self.get_object()

        if instance.student_id_id != request.user.student_id:
            return Response(
                {"error": "You are not authorized to update this record."},
                status=status.HTTP_403_FORBIDDEN
            )
        
        data = request.data

        # Update fields for the class schedule
        allowed_fields = [
            "subject_code", "subject_title", "semester_id",
            "day_of_week", "scheduled_start_time", "scheduled_end_time", "room"
        ]
        
        # Validate and sanitize input
        for field in allowed_fields:
            if field not in data or data[field] in [None, ""]:
                return Response(
                    {"error": f"Field '{field}' is required and cannot be blank."},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
        try:
            subject = instance.subject  # The subject linked to the class you're editing

            # Optional: prevent changing to a duplicate subject_code for same student and semester
            if CustomSubject.objects.exclude(subject_id=subject.subject_id).filter(
                subject_code=data["subject_code"],
                student_id=request.user,
                semester_id=data["semester_id"]
            ).exists():
                return Response(
                    {"error": "A subject with this code already exists."},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Update the subject fields
            subject.subject_code = data["subject_code"]
            subject.subject_title = data["subject_title"]
            subject.semester_id_id = data["semester_id"]  # optional if not changing semesters
            subject.save()

            # Update the class schedule instance
            instance.subject = subject
            instance.day_of_week = data["day_of_week"]
            instance.scheduled_start_time = data["scheduled_start_time"]
            instance.scheduled_end_time = data["scheduled_end_time"]
            instance.room = data["room"]
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

        if instance.student_id_id != request.user.student_id:
            raise PermissionDenied("You are not authorized to delete this record.")

        subject = instance.subject

        with transaction.atomic():
            # Delete related ScheduleEntry records manually
            ScheduleEntry.objects.filter(
                category_type='Class',
                reference_id=instance.classsched_id,
                student_id=instance.student_id
            ).delete()
            
            self.perform_destroy(instance)

            # Check if the subject is still referenced in any other records *belonging to the same user*
            if not CustomClassSchedule.objects.filter(
                subject=subject,
                student_id=request.user.student_id
            ).exists(): 
                subject.delete()

        return Response(status=status.HTTP_204_NO_CONTENT)

# Subject
class SubjectViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.AllowAny]
    serializer_class = CustomSubjectSerializer

    def get_queryset(self):
        # Filter subjects based on the logged-in user
        queryset = CustomSubject.objects.filter(student_id=self.request.user.student_id)

        # Apply semester_id filtering if provided in query params
        semester_id = self.request.query_params.get('semester_id')
        if semester_id:
            queryset = queryset.filter(semester_id=semester_id)

        return queryset
    
    def update(self, request, *args, **kwargs):
        instance = self.get_object()

        # Ownership check
        if instance.student_id != request.user.student_id:
            return Response(
                {"error": "You are not authorized to update this record."},
                status=status.HTTP_403_FORBIDDEN
            )

        return super().update(request, *args, **kwargs)

    @action(detail=False, methods=['get'], url_path='(?P<subject_code>[^/.]+)')
    def get_subject_by_code(self, request, subject_code):
        try:
            subject = CustomSubject.objects.get(
                subject_code=subject_code, 
                student_id=request.user.student_id
            )
            serializer = self.get_serializer(subject)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except CustomSubject.DoesNotExist:
            return Response({'error': 'Subject not found'}, status=status.HTTP_404_NOT_FOUND)

# Semester
class SemesterViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.AllowAny]
    serializer_class = CustomSemesterSerializer

    def get_queryset(self):
        # Retrieve semesters linked to the logged-in user
        return CustomSemester.objects.filter(student_id=self.request.user.student_id)

    def perform_create(self, serializer):
        # Automatically link the semester to the logged-in user
        serializer.save(student_id=self.request.user.student_id)

    @action(detail=False, methods=['get'], url_path='filter')
    def filter_semesters(self, request):
        queryset = self.get_queryset()

        # Optional query parameters for filtering
        acad_year_start = request.query_params.get('acad_year_start')
        year_level = request.query_params.get('year_level')
        semester = request.query_params.get('semester')

        if acad_year_start:
            queryset = queryset.filter(acad_year_start=acad_year_start)
        if year_level:
            queryset = queryset.filter(year_level=year_level)
        if semester:
            queryset = queryset.filter(semester=semester)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    @action(detail=False, methods=['post'])
    def add_semester(self, request):
        data = request.data

        # Extract data from request
        acad_year_start = data.get('acad_year_start')
        acad_year_end = data.get('acad_year_end')
        year_level = data.get('year_level')
        semester = data.get('semester')
        sem_start_date = data.get('sem_start_date')
        sem_end_date = data.get('sem_end_date')
        student_id = request.user.student_id  # Authenticated user

        # Validate input
        if not all([acad_year_start, acad_year_end, year_level, semester, sem_start_date, sem_end_date]):
            return Response({'error': 'All fields are required except student_id.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Fetch the CustomUser instance
            student = CustomUser.objects.get(student_id=student_id)

            # Check for duplicate semester
            duplicate = CustomSemester.objects.filter(
                Q(acad_year_start=acad_year_start) &
                Q(acad_year_end=acad_year_end) &
                Q(year_level=year_level) &
                Q(semester=semester) &
                Q(student_id=student)
            ).exists()

            if duplicate:
                return Response(
                    {'error': 'Duplicate semester entry detected.'},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Create Semester
            semester = CustomSemester.objects.create(
                acad_year_start=acad_year_start,
                acad_year_end=acad_year_end,
                year_level=year_level,
                semester=semester,
                sem_start_date=sem_start_date,
                sem_end_date=sem_end_date,
                student_id=student,
            )

            # Serialize and return the created data
            serializer = self.get_serializer(semester)
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


        acad_year_start = data.get('acad_year_start')
        acad_year_end = data.get('acad_year_end')
        year_level = data.get('year_level')
        semester = data.get('semester')
        sem_start_date = data.get('sem_start_date')
        sem_end_date = data.get('sem_end_date')

        if not all([acad_year_start, acad_year_end, year_level, semester, sem_start_date, sem_end_date]):
            return Response({'error': 'All fields are required.'}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            instance.acad_year_start = acad_year_start
            instance.acad_year_end = acad_year_end
            instance.year_level = year_level
            instance.semester = semester
            instance.sem_start_date = sem_start_date
            instance.sem_end_date = sem_end_date
            instance.save()

            serializer = self.get_serializer(instance)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except ValidationError as ve:
            return Response({'error': str(ve)}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response(
                {'error': f'An error occurred: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    


# Class Attendance
class AttendedClassViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.AllowAny]
    serializer_class = AttendedClassSerializer

    def get_queryset(self):
        # Filter attended classes based on the logged-in user
        queryset = AttendedClass.objects.filter(classsched_id__student_id=self.request.user)

        # Apply date filtering if provided in query params
        start_date = self.request.query_params.get('start_date')
        end_date = self.request.query_params.get('end_date')
        if start_date and end_date:
            queryset = queryset.filter(attendance_date__range=[start_date, end_date])

        # Apply classsched_id filtering if provided in query params
        classsched_id = self.request.query_params.get('classsched_id')
        if classsched_id:
            queryset = queryset.filter(classsched_id=classsched_id)

        return queryset
    
    @action(detail=False, methods=['post'])
    def mark_attendance(self, request):
        data = request.data

        classsched_id = data.get('classsched_id')
        attendance_date = data.get('attendance_date')
        attendance_status = data.get('status', "Did Not Attend")

        # Validate input
        if not all([classsched_id, attendance_date]):
            return Response(
                {'error': 'classsched_id and attendance_date are required.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            # Validate the class exists
            classes = CustomClassSchedule.objects.get(classsched_id=classsched_id, student_id=request.user)

            # Check if attendance already exists for the class
            attendance, created = AttendedClass.objects.get_or_create(
                classsched_id=classes,
                attendance_date=attendance_date,
                defaults={'status': attendance_status}
            )

            if not created:
                # Update the existing attendance record
                attendance.status = attendance_status
                attendance.save()
                return Response(
                    {'message': 'Attendance updated successfully.'},
                    status=status.HTTP_200_OK
                )

            # Serialize and return the new attendance
            serializer = self.get_serializer(attendance)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        except CustomClassSchedule.DoesNotExist:
            return Response(
                {'error': 'ClassSchedule not found or not associated with the logged-in user.'},
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            return Response(
                {'error': f'An error occurred: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

# Task
class TaskViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.AllowAny]
    serializer_class = CustomTaskSerializer

    def get_queryset(self):
        # Filter tasks based on the logged-in user
        queryset = CustomTask.objects.filter(student_id=self.request.user)
    
        # Apply scheduled_date filtering if provided in query params
        start_date = self.request.query_params.get('start_date')
        end_date = self.request.query_params.get('end_date')

        if start_date and end_date:
            queryset = queryset.filter(scheduled_date__range=[start_date, end_date])

        return queryset
    
    @action(detail=False, methods=['get'])
    def pending_tasks(self, request):
        #Get tasks that are still pending
        tasks = CustomTask.objects.filter(
            student_id=request.user.student_id,
            status='Pending'
        )
        serializer = self.get_serializer(tasks, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def completed_tasks(self, request):
        #Get tasks that have been completed
        tasks = CustomTask.objects.filter(
            student_id=request.user.student_id,
            status='Completed'
        )
        serializer = self.get_serializer(tasks, many=True)
        return Response(serializer.data)

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
        subject_id = data.get('subject_id')
        student_id = request.user.student_id  # Authenticated user

        if task_desc is not None and isinstance(task_desc, str) and task_desc.strip() == '':
            task_desc = None

        # Validate input
        if not all([task_name, scheduled_date, start_time, end_time, deadline_str, subject_id]):
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
            subject = get_object_or_404(CustomSubject, subject_id=subject_id)

            # Fetch the CustomUser instance
            student = CustomUser.objects.get(student_id=student_id)

            # Check for duplicate task schedule
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
            
            # Check for overlapping schedules
            overlapping_schedules = ScheduleEntry.objects.filter(
                student_id=student,
                scheduled_date=scheduled_date
            ).filter(
                Q(scheduled_start_time__lt=end_time, scheduled_end_time__gt=start_time)
            )

            if overlapping_schedules.exists():
                return Response({'error_type': 'overlap', 'message': 'This time slot is already occupied. Please choose another time.'}, status=status.HTTP_400_BAD_REQUEST)

            # Create Task
            task = CustomTask.objects.create(
                task_name=task_name,
                task_desc=task_desc or None,
                scheduled_date=scheduled_date,
                scheduled_start_time=start_time,
                scheduled_end_time=end_time,
                deadline=deadline,
                status='Pending',
                subject_id=subject,
                student_id=student,
            )

            # Create ScheduleEntry
            ScheduleEntry.objects.create(
                category_type='Task',
                reference_id=task.task_id,  # FK reference to the created task
                student_id=student,
                scheduled_date=scheduled_date,
                scheduled_start_time=start_time,
                scheduled_end_time=end_time
            )
            print(f"ScheduleEntry created successfully!")

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
        subject_id = data.get('subject_id')

        # Validate input
        if not all([task_name, scheduled_date, start_time, end_time, deadline_str, subject_id]):
            return Response({'error': 'All fields are required.'}, status=status.HTTP_400_BAD_REQUEST)

        # Parse scheduled_date, start_time, end_time
        try:
            if isinstance(scheduled_date, str):
                scheduled_date = datetime.fromisoformat(scheduled_date).date()

            if isinstance(start_time, str):
                start_time = dtime.fromisoformat(start_time)

            if isinstance(end_time, str):
                end_time = dtime.fromisoformat(end_time)
        except ValueError as ve:
            return Response(
                {'error': f'Invalid date/time format: {ve}'},
                status=status.HTTP_400_BAD_REQUEST
            )

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
            subject = get_object_or_404(CustomSubject, subject_id=subject_id)

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
            
            # Check for overlapping schedules
            overlapping_schedules = ScheduleEntry.objects.filter(
                student_id=instance.student_id,
                scheduled_date=scheduled_date
            ).filter(
                Q(scheduled_start_time__lt=end_time, scheduled_end_time__gt=start_time)
            ).exclude(
                Q(category_type='Task') & Q(reference_id=instance.task_id)  # Exclude the current task entry
            )

            if overlapping_schedules.exists():
                return Response({'error_type': 'overlap', 'message': 'This time slot is already occupied. Please choose another time.'}, status=status.HTTP_400_BAD_REQUEST)

            # Reset reminder_sent if event is moved to a future datetime
            old_dt = timezone.make_aware(datetime.combine(instance.scheduled_date, instance.scheduled_start_time))
            new_dt = timezone.make_aware(datetime.combine(scheduled_date, start_time))
            if instance.reminder_sent and new_dt > old_dt:
                instance.reminder_sent = False
            
            # Update the task instance
            instance.task_name = task_name
            instance.task_desc = task_desc
            instance.scheduled_date = scheduled_date
            instance.scheduled_start_time = start_time
            instance.scheduled_end_time = end_time
            instance.deadline = deadline
            instance.subject_id = subject
            instance.save()

            # Update the related ScheduleEntry
            schedule_entry = ScheduleEntry.objects.filter(
                category_type='Task',
                reference_id=instance.task_id
            ).first()

            if schedule_entry:
                schedule_entry.scheduled_date = scheduled_date
                schedule_entry.scheduled_start_time = start_time
                schedule_entry.scheduled_end_time = end_time
                schedule_entry.save()

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
        
# Task Time Log
class TaskTimeLogViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.AllowAny]
    serializer_class = TaskLogSerializer

    def get_queryset(self):
        # Filter logged tasks based on the logged-in user
        queryset = TaskTimeLog.objects.filter(task_id__student_id=self.request.user)
    
        # Apply date_logged filtering if provided in query params
        start_date = self.request.query_params.get('start_date')
        end_date = self.request.query_params.get('end_date')

        if start_date and end_date:
            queryset = queryset.filter(date_logged__range=[start_date, end_date])

        return queryset
    
    @action(detail=False, methods=['post'])
    def log_time(self, request):
        data = request.data

        task_id = data.get('task_id')
        start_time = data.get('start_time')
        end_time = data.get('end_time')
        duration = data.get('duration')
        date_logged = data.get('date_logged')

        # Validate input
        if not all([task_id, start_time, end_time, duration, date_logged]):
            return Response(
                {'error': 'Missing fields.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            # Validate the task exists
            task = CustomTask.objects.get(task_id=task_id, student_id=request.user)

            # Check if a time log already exists for the same task and date
            existing_log = TaskTimeLog.objects.filter(
                task_id=task,
                date_logged=date_logged
            ).first()

            if existing_log:
                return Response(
                    {'error': 'A time log for this task and date already exists.'},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Convert duration from string to timedelta
            hours, minutes, seconds = map(int, duration.split(':'))
            duration_timedelta = timedelta(hours=hours, minutes=minutes, seconds=seconds)

            # Create the time log
            log = TaskTimeLog.objects.create(
                task_id=task,
                start_time=start_time,
                end_time=end_time,
                duration=duration_timedelta,
                date_logged=date_logged
            )

            # Update the task status to "Completed"
            task.status = "Completed"
            task.save()

            # Serialize and return the created time log
            serializer = self.get_serializer(log)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        except CustomTask.DoesNotExist:
            return Response(
                {'error': 'Task not found or not associated with the logged-in user.'},
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            return Response(
                {'error': f'An error occurred: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

# Goals
class GoalViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.AllowAny]
    serializer_class = GoalsSerializer

    def get_queryset(self):
        return Goals.objects.filter(student_id=self.request.user)

    @action(detail=False, methods=['post'])
    def add_goal(self, request):
        data = request.data

        # Extract data from request
        goal_name = data.get('goal_name')
        goal_desc = data.get('goal_desc')
        timeframe = data.get('timeframe')
        target_hours = data.get('target_hours')
        goal_type = data.get('goal_type')
        semester_id = data.get('semester_id')
        student_id = request.user.student_id

        if goal_desc is not None and isinstance(goal_desc, str) and goal_desc.strip() == '':
            goal_desc = None

        # Validate input
        if not all([goal_name, timeframe, target_hours, goal_type]):
            return Response({'error': 'All fields are required.'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Additional validation for `semester_id` based on `goal_type`
        if goal_type == 'Academic' and not semester_id:
            return Response({'error': 'semester_id is required for Academic goals.'}, status=status.HTTP_400_BAD_REQUEST)
        elif goal_type == 'Personal' and semester_id is not None:
            return Response({'error': 'semester_id must be null for Personal goals.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Fetch the CustomUser instance
            student = CustomUser.objects.get(student_id=student_id)

            semester = None
            if goal_type == 'Academic':
                semester = get_object_or_404(CustomSemester, semester_id=semester_id)

            # Check for duplicate goal instance
            duplicate = Goals.objects.filter(
                Q(goal_name=goal_name) &
                Q(timeframe=timeframe) &
                Q(target_hours=target_hours) &
                (Q(semester_id=semester) if semester else Q(semester_id__isnull=True)) &
                Q(student_id=student)
            ).exists()

            if duplicate:
                return Response(
                    {'error': 'Duplicate goal instance detected.'},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Create Goal
            goal = Goals.objects.create(
                goal_name=goal_name,
                goal_desc=goal_desc or None,
                timeframe=timeframe,
                target_hours=target_hours,
                goal_type=goal_type,
                semester_id=semester,
                student_id=student,
            )

            # Serialize and return the created data
            serializer = self.get_serializer(goal)
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
        goal_name = data.get('goal_name')
        goal_desc = data.get('goal_desc')
        timeframe = data.get('timeframe')
        target_hours = data.get('target_hours')
        goal_type = data.get('goal_type')
        semester_id = data.get('semester_id')

        if goal_desc is not None and isinstance(goal_desc, str) and goal_desc.strip() == '':
            goal_desc = None

        # Validate input
        if not all([goal_name, timeframe, target_hours, goal_type]):
            return Response({'error': 'All fields are required.'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Additional validation for `semester_id` based on `goal_type`
        if goal_type == 'Academic' and not semester_id:
            return Response({'error': 'semester_id is required for Academic goals.'}, status=status.HTTP_400_BAD_REQUEST)
        elif goal_type == 'Personal' and semester_id:
            return Response({'error': 'semester_id must be null for Personal goals.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            semester = None
            if goal_type == 'Academic':
                semester = get_object_or_404(CustomSemester, semester_id=semester_id)

            # Check for duplicate goal instance
            duplicate = Goals.objects.filter(
                Q(goal_name=goal_name) &
                Q(timeframe=timeframe) &
                Q(target_hours=target_hours) &
                (Q(semester_id=semester) if semester else Q(semester_id__isnull=True)) &
                Q(student_id=instance.student_id) &
                ~Q(goal_id=instance.goal_id)
            ).exists()

            if duplicate:
                return Response(
                    {'error': 'Duplicate goal instance detected.'},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Update the goal instance
            instance.goal_name = goal_name
            instance.goal_desc = goal_desc
            instance.timeframe = timeframe
            instance.target_hours = target_hours
            instance.goal_type = goal_type
            instance.semester_id = semester
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
        
# Goal Schedule
class GoalScheduleViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.AllowAny]
    serializer_class = GoalScheduleSerializer

    def get_queryset(self):
        # Filter goal schedule based on the logged-in user
        queryset = GoalSchedule.objects.filter(goal_id__student_id=self.request.user)

        # Apply goal_id filtering if provided in query params
        goal_id = self.request.query_params.get('goal_id')
        if goal_id:
            queryset = queryset.filter(goal_id=goal_id)

        return queryset
    
    @action(detail=False, methods=['get'])
    def pending_goal_schedules(self, request):
        # Get goal schedules that are still pending
        schedules = GoalSchedule.objects.filter(
            goal_id__student_id=request.user.student_id,
            status='Pending'
        )
        serializer = self.get_serializer(schedules, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def completed_goal_schedules(self, request):
        # Get goal schedules that have been completed
        schedules = GoalSchedule.objects.filter(
            goal_id__student_id=request.user.student_id,
            status='Completed'
        )
        serializer = self.get_serializer(schedules, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['post'])
    def add_schedule(self, request):
        data = request.data

        # Extract data from request
        goal_id = data.get('goal_id')
        scheduled_date = data.get('scheduled_date')
        scheduled_start_time = data.get('scheduled_start_time')
        scheduled_end_time = data.get('scheduled_end_time')

        # Validate input
        if not all([scheduled_date, scheduled_start_time, scheduled_end_time]):
            return Response({'error': 'All fields are required except student_id.'}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            # Fetch the CustomUser instance
            goal = get_object_or_404(Goals, goal_id=goal_id)

            student = CustomUser.objects.get(student_id=request.user.student_id)

            # Check for duplicate goal instance
            duplicate = GoalSchedule.objects.filter(
                Q(goal_id=goal) &
                Q(scheduled_date=scheduled_date) &
                Q(scheduled_start_time=scheduled_start_time) &
                Q(scheduled_end_time=scheduled_end_time)
            ).exists()

            if duplicate:
                return Response(
                    {'error': 'Duplicate goal instance detected.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Check for overlapping schedules
            overlapping_schedules = ScheduleEntry.objects.filter(
                student_id=student,
                scheduled_date=scheduled_date
            ).filter(
                Q(scheduled_start_time__lt=scheduled_end_time, scheduled_end_time__gt=scheduled_start_time)
            )

            if overlapping_schedules.exists():
                return Response({'error_type': 'overlap', 'message': 'This time slot is already occupied. Please choose another time.'}, status=status.HTTP_400_BAD_REQUEST)

            # Create Goal Schedule
            goalSchedule = GoalSchedule.objects.create(
                goal_id=goal,
                scheduled_date=scheduled_date,
                scheduled_start_time=scheduled_start_time,
                scheduled_end_time=scheduled_end_time,
                status='Pending',
            )

            # Create ScheduleEntry
            ScheduleEntry.objects.create(
                category_type='Goal',
                reference_id=goalSchedule.goalschedule_id,  # FK reference to the created goal schedule
                student_id=student,
                scheduled_date=scheduled_date,
                scheduled_start_time=scheduled_start_time,
                scheduled_end_time=scheduled_end_time
            )
            print(f"ScheduleEntry created successfully!")

            # Serialize and return the created data
            serializer = self.get_serializer(goalSchedule)
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

        # Update fields for the goal schedule
        goal_id = data.get('goal_id')
        scheduled_date = data.get('scheduled_date')
        scheduled_start_time = data.get('scheduled_start_time')
        scheduled_end_time = data.get('scheduled_end_time')

        # Validate input
        if not all([scheduled_date, scheduled_start_time, scheduled_end_time]):
            return Response({'error': 'All fields are required except student_id.'}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            # Fetch the CustomUser instance
            goal = get_object_or_404(Goals, goal_id=goal_id)

            student = CustomUser.objects.get(student_id=request.user.student_id)

            # Check for duplicate goal instance
            duplicate = GoalSchedule.objects.filter(
                Q(goal_id=goal) &
                Q(scheduled_date=scheduled_date) &
                Q(scheduled_start_time=scheduled_start_time) &
                Q(scheduled_end_time=scheduled_end_time) &
                ~Q(goalschedule_id=instance.goalschedule_id)
            ).exists()

            if duplicate:
                return Response(
                    {'error': 'Duplicate goal instance detected.'},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Check for overlapping schedules
            overlapping_schedules = ScheduleEntry.objects.filter(
                student_id=student,
                scheduled_date=scheduled_date
            ).filter(
                Q(scheduled_start_time__lt=scheduled_end_time, scheduled_end_time__gt=scheduled_start_time)
            ).exclude(
                Q(category_type='Goal') & Q(reference_id=instance.goalschedule_id)  # Exclude the current goal schedule entry
            )

            if overlapping_schedules.exists():
                return Response({'error_type': 'overlap', 'message': 'This time slot is already occupied. Please choose another time.'}, status=status.HTTP_400_BAD_REQUEST)

            # Update the task instance
            instance.goal_id = goal
            instance.scheduled_date = scheduled_date
            instance.scheduled_start_time = scheduled_start_time
            instance.scheduled_end_time = scheduled_end_time
            instance.save()

            # Update the related ScheduleEntry
            schedule_entry = ScheduleEntry.objects.filter(
                category_type='Goal',
                reference_id=instance.goalschedule_id
            ).first()

            if schedule_entry:
                schedule_entry.scheduled_date = scheduled_date
                schedule_entry.scheduled_start_time = scheduled_start_time
                schedule_entry.scheduled_end_time = scheduled_end_time
                schedule_entry.save()

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

# Goal Progress
class GoalProgressViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.AllowAny]
    serializer_class = GoalProgressSerializer

    def get_queryset(self):
        # Filter logged goal sessions based on the logged-in user
        queryset = GoalProgress.objects.filter(goal_id__student_id=self.request.user)

        # Apply goal_id and date_logged filtering if provided in query params
        goal_id = self.request.query_params.get('goal_id')
        start_date = self.request.query_params.get('start_date')
        end_date = self.request.query_params.get('end_date')

        # Filter based on provided parameters
        if goal_id:
            queryset = queryset.filter(goal_id=goal_id)
        if start_date and end_date:
            queryset = queryset.filter(session_date__range=[start_date, end_date])
        elif start_date:
            queryset = queryset.filter(session_date__gte=start_date)
        elif end_date:
            queryset = queryset.filter(session_date__lte=end_date)

        return queryset
    
    @action(detail=False, methods=['post'])
    def log_time(self, request):
        data = request.data

        goal_id = data.get('goal_id')
        goalschedule_id = data.get('goalschedule_id')
        session_date = data.get('session_date')
        session_start_time = data.get('session_start_time')
        session_end_time = data.get('session_end_time')
        session_duration = data.get('session_duration')

        # Validate input
        if not all([goal_id, goalschedule_id, session_date, session_start_time, session_end_time, session_duration]):
            return Response(
                {'error': 'Missing fields.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            # Validate the goal and goal schedule exists
            goal = Goals.objects.get(goal_id=goal_id, student_id=request.user)
            schedule = GoalSchedule.objects.get(goalschedule_id=goalschedule_id, goal_id=goal)

            # Check if a time log already exists for the same goal schedule and date
            existing_log = GoalProgress.objects.filter(
                goal_id=goal,
                goalschedule_id=schedule,
                session_date=session_date
            ).first()

            if existing_log:
                return Response(
                    {'error': 'A time log for this goal schedule and date already exists.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Convert duration from string to timedelta
            hours, minutes, seconds = map(int, session_duration.split(':'))
            duration_timedelta = timedelta(hours=hours, minutes=minutes, seconds=seconds)

            # Check if attendance already exists for the event
            log = GoalProgress.objects.create(
                goal_id=goal,
                goalschedule_id=schedule,
                session_date=session_date,
                session_start_time=session_start_time,
                session_end_time=session_end_time,
                session_duration=duration_timedelta
            )

            # Update the goal schedule status to "Completed"
            schedule.status = "Completed"
            schedule.save()

            # Serialize and return the new attendance
            serializer = self.get_serializer(log)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        except Goals.DoesNotExist:
            return Response(
                {'error': 'Goal not found or not associated with the logged-in user.'},
                status=status.HTTP_404_NOT_FOUND
            )
        except GoalSchedule.DoesNotExist:
            return Response(
                {'error': 'Goal schedule not found or not associated with the logged-in user.'},
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            return Response(
                {'error': f'An error occurred: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

#Sleep
class SleepLogViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.AllowAny]
    serializer_class = SleepLogSerializer

    def get_queryset(self):
        # Filter logged sleep sessions based on the logged-in user
        queryset = SleepLog.objects.filter(student_id=self.request.user)

        # Apply date_logged filtering if provided in query params
        start_date = self.request.query_params.get('start_date')
        end_date = self.request.query_params.get('end_date')

        if start_date and end_date:
            queryset = queryset.filter(date_logged__range=[start_date, end_date])

        return queryset
    
    @action(detail=False, methods=['post'])
    def log_time(self, request):
        data = request.data

        start_time = data.get('start_time')
        end_time = data.get('end_time')
        duration = data.get('duration')
        date_logged = data.get('date_logged')
        student_id = request.user.student_id

        # Validate input
        if not all([start_time, end_time, duration, date_logged]):
            return Response(
                {'error': 'Missing fields.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            # Fetch the CustomUser instance
            student = CustomUser.objects.get(student_id=student_id)

            hours, minutes, seconds = map(int, duration.split(':'))
            duration_timedelta = timedelta(hours=hours, minutes=minutes, seconds=seconds)

            # Create Sleep Log
            sleep = SleepLog.objects.create(
                student_id=student,
                start_time=start_time,
                end_time=end_time,
                duration=duration_timedelta,
                date_logged=date_logged
            )

            # Serialize and return the created data
            serializer = self.get_serializer(sleep)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        except CustomUser.DoesNotExist:
            return Response(
                {'error': 'Authenticated user not found in CustomUser table.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            return Response(
                {'error': f'An error occurred: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


# Schedule Entry
class ScheduleEntryViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.AllowAny]
    serializer_class = ScheduleEntrySerializer

    def get_queryset(self):
        return ScheduleEntry.objects.filter(student_id=self.request.user)

    @action(detail=False, methods=['delete'])
    def delete_filtered(self, request):
        category_type = request.query_params.get('category_type')
        reference_id = request.query_params.get('reference_id')

        if not category_type or not reference_id:
            return Response({"error": "category_type and reference_id are required"},
                            status=status.HTTP_400_BAD_REQUEST)

        deleted_count, _ = ScheduleEntry.objects.filter(
            student_id=request.user,
            category_type=category_type,
            reference_id=reference_id
        ).delete()

        return Response({"deleted": deleted_count}, status=status.HTTP_200_OK)

        
    
# Firebase Cloud Messaging (Push Notifs)
class FCMTokenViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = FCMTokenSerializer
    queryset = FCMToken.objects.all()

    def get_queryset(self):
        # Only allow users to access their own FCM token
        return self.queryset.filter(user=self.request.user)

    @action(detail=False, methods=['post'])
    def register(self, request):
        """
        Registers or updates the FCM token for the authenticated user.
        """
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            token = serializer.validated_data['token']
            fcm_token, created = FCMToken.objects.update_or_create(
                user=request.user,
                defaults={'token': token}
            )
            return Response({
                "message": "Token saved successfully.",
                "created": created
            }, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    

class YourUserViewSet(viewsets.ModelViewSet):
    queryset = CustomUser.objects.all()
    serializer_class = UserSerializer

    @action(detail=False, methods=['post'], url_path='test-push')
    def test_push_notification(self, request):
        student_id = request.data.get('student_id')
        if not student_id:
            return Response({"error": "Missing student_id"}, status=400)

        # Send a test push
        send_push_notification.delay(
            student_id,
            "🔔 Test Push",
            "This is a manual test notification"
        )
        return Response({"status": "Push triggered"}, status=200)