from django.urls import path, include
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

router.register(r'userprefs', UserPreferenceView, basename='userpref')
router.register(r'users', CustomUserViewSet, basename='user')


urlpatterns = [
    path ('djoser/', include ('djoser.urls')),
    path ('auth/', include ('djoser.urls.jwt')),
    #ModelViewSet
    path('', include(router.urls)),
    
    #actlog
    path('createactlog/', LogActivityListCreateView.as_view(), name='actlog-list-create'),
    path('actlog/<uuid:pk>/', LogActivityDetailView.as_view(), name='actlog-detail'),
    path('deleteactlog/<int:pk>/', LogActivityDeleteView.as_view(), name='actlog-delete'),
    path('updateactlog/<int:pk>/',LogActivityUpdateView.as_view(), name='updateactlog' ),
    #attended class
    path('createclassatt/', AttClassListCreateView.as_view(), name='attclass-list-create'),
    path('classatt/<uuid:pk>/', AttClassDetailView.as_view(), name='attclass-detail'),
    path('deleteclassatt/<int:pk>/', AttClassDeleteView.as_view(), name='attclass-delete'),
    path('updateclassatt/<int:pk>/',AttClassUpdateView.as_view(), name='updateattclass' ),
    #goal prog
    path('creategoalprog/', GoalProgressListCreateView.as_view(), name='goalprog-list-create'),
    path('goalprog/<uuid:pk>/', GoalProgressDetailView.as_view(), name='goalprog-detail'),
    path('deletegoalprog/<int:pk>/', GoalProgressDeleteView.as_view(), name='goalprog-delete'),
    path('updategoalprog/<int:pk>/',GoalProgressUpdateView.as_view(), name='updategoalprog' ),
    #sleep log
    path('createsleeplog/', SleepLogListCreateView.as_view(), name='sleeplog-list-create'),
    path('sleeplog/<uuid:pk>/', SleepLogDetailView.as_view(), name='sleeplog-detail'),
    path('deletesleeplog/<int:pk>/', SleepLogDeleteView.as_view(), name='sleeplog-delete'),
    path('updatesleeplog/<int:pk>/', SleepLogUpdateView.as_view(), name='updatesleeplog' ),
]
