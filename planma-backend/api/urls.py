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


router.register(r'userprefs', UserPrefListCreateView, basename='userpref')


urlpatterns = [
    path ('djoser/', include ('djoser.urls')),
    path ('auth/', include ('djoser.urls.jwt')),
    #ModelViewSet
    path('', include(router.urls)),
    path('createattevents/', AttendedEventListCreateView.as_view(), name='attevent-list-create'),
    path('attevents/<uuid:pk>/', AttendedEventDetailView.as_view(), name='attevent-detail'),
    path('deleteattevents/<int:pk>/', AttendedEventDeleteView.as_view(), name='attevent-delete'),
    path('updateattevent/<int:pk>/',AttendedEventUpdateView.as_view(), name='updateattevent' ),
    #activity
    # path('createactivity/', CustomActivityListCreateView.as_view(), name='activity-list-create'),
    # path('activities/<uuid:pk>/', CustomActivityDetailView.as_view(), name='activity-detail'),
    # path('deleteactivity/<int:pk>/', CustomActivityDeleteView.as_view(), name='activity-delete'),
    # path('updateactivity/<int:pk>/',CustomActivityUpdateView.as_view(), name='updateactivity' ),
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
