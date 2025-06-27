from django.conf import settings
from django.urls import path, include
from django.conf.urls.static import static
from rest_framework.routers import DefaultRouter
from .views import *

router = DefaultRouter()
router.register(r'class-schedules', ClassScheduleViewSet, basename='classschedule')
router.register(r'subjects', SubjectViewSet, basename='subject')
router.register(r'semesters', SemesterViewSet, basename='semester')
router.register(r'tasks', TaskViewSet, basename='task')
router.register(r'events', EventViewSet, basename='event')
router.register(r'goals', GoalViewSet, basename='goal')
router.register(r'goal-schedules', GoalScheduleViewSet, basename='goalschedule')
router.register(r'activities', ActivityViewSet, basename='activity')
router.register(r'attended-events', AttendedEventViewSet, basename='attendedevent')
router.register(r'activity-logs', ActivityTimeLogViewSet, basename='activitylog')
router.register(r'task-logs', TaskTimeLogViewSet, basename='tasklog')
router.register(r'goal-progress', GoalProgressViewSet, basename='goalprogress')
router.register(r'attended-classes', AttendedClassViewSet, basename='attendedclass')
router.register(r'sleep-logs', SleepLogViewSet, basename='sleeplog')
router.register(r'userprefs', UserPreferenceView, basename='userpref')
router.register(r'users', CustomUserViewSet, basename='user')
router.register(r'schedule', ScheduleEntryViewSet, basename='schedule')
router.register(r'fcm-token', FCMTokenViewSet, basename='fcm-token')
router.register(r'your-user', YourUserViewSet, basename='your-user')

urlpatterns = [
    path ('djoser/', include ('djoser.urls')),
    path('auth/jwt/create/', CustomTokenObtainPairView.as_view(), name='jwt-create'),
    path ('auth/', include ('djoser.urls.jwt')), 
    path('', include(router.urls)),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
