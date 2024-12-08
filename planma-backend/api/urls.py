from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import *

router = DefaultRouter()
router.register(r'class-schedules', ClassScheduleViewSet, basename='classschedule')
router.register(r'subjects', SubjectViewSet, basename='subject')
router.register(r'semesters', SemesterViewSet, basename='semester')
router.register(r'tasks', TaskViewSet, basename='task')
router.register(r'events', EventViewSet, basename='event')



urlpatterns = [
    path ('djoser/', include ('djoser.urls')),
    path ('auth/', include ('djoser.urls.jwt')),
    #ModelViewSet
    path('', include(router.urls)),
    #events
    path('createevents/', CustomEventListCreateView.as_view(), name='event-list-create'),
    # path('events/<uuid:pk>/', CustomEventDetailView.as_view(), name='event-detail'),
    # path('deleteevent/<int:pk>/', CustomEventDeleteView.as_view(), name='event-delete'),
    # path('updateevent/<int:pk>/',CustomEventUpdateView.as_view(), name='updateevent' ),
    # attended event
    path('createattevents/', AttendedEventListCreateView.as_view(), name='attevent-list-create'),
    path('attevents/<uuid:pk>/', AttendedEventDetailView.as_view(), name='attevent-detail'),
    path('deleteattevents/<int:pk>/', AttendedEventDeleteView.as_view(), name='attevent-delete'),
    path('updateattevent/<int:pk>/',AttendedEventUpdateView.as_view(), name='updateattevent' ),
    #activity
    path('createactivity/', CustomActivityListCreateView.as_view(), name='activity-list-create'),
    path('activities/<uuid:pk>/', CustomActivityDetailView.as_view(), name='activity-detail'),
    path('deleteactivity/<int:pk>/', CustomActivityDeleteView.as_view(), name='activity-delete'),
    path('updateactivity/<int:pk>/',CustomActivityUpdateView.as_view(), name='updateactivity' ),
    #actlog
    path('createactlog/', LogActivityListCreateView.as_view(), name='actlog-list-create'),
    path('actlog/<uuid:pk>/', LogActivityDetailView.as_view(), name='actlog-detail'),
    path('deleteactlog/<int:pk>/', LogActivityDeleteView.as_view(), name='actlog-delete'),
    path('updateactlog/<int:pk>/',LogActivityUpdateView.as_view(), name='updateactlog' ),
    #userpref
    path('createuserpref/', UserPrefListCreateView.as_view(), name='userpref-list-create'),
    path('userpref/<uuid:pk>/', UserPrefDetailView.as_view(), name='userpref-detail'),
    path('deleteuserpref/<int:pk>/', UserPrefDeleteView.as_view(), name='userpref-delete'),
    path('updateuserpref/<int:pk>/',UserPrefUpdateView.as_view(), name='updateuserpref' ),
    #attended class
    path('createclassatt/', AttClassListCreateView.as_view(), name='attclass-list-create'),
    path('classatt/<uuid:pk>/', AttClassDetailView.as_view(), name='attclass-detail'),
    path('deleteclassatt/<int:pk>/', AttClassDeleteView.as_view(), name='attclass-delete'),
    path('updateclassatt/<int:pk>/',AttClassUpdateView.as_view(), name='updateattclass' ),
    #goals
    path('creategoals/', GoalsListCreateView.as_view(), name='goals-list-create'),
    path('goals/<uuid:pk>/', GoalsDetailView.as_view(), name='goals-detail'),
    path('deletegoals/<int:pk>/', GoalsDeleteView.as_view(), name='goals-delete'),
    path('updategoals/<int:pk>/',GoalsUpdateView.as_view(), name='updategoals' ),
    #goal prog
    path('creategoalprog/', GoalProgressListCreateView.as_view(), name='goalprog-list-create'),
    path('goalprog/<uuid:pk>/', GoalProgressDetailView.as_view(), name='goalprog-detail'),
    path('deletegoalprog/<int:pk>/', GoalProgressDeleteView.as_view(), name='goalprog-delete'),
    path('updategoalprog/<int:pk>/',GoalProgressUpdateView.as_view(), name='updategoalprog' ),
    #goal sched
    path('creategoalsched/', GoalScheduleListCreateView.as_view(), name='goalsched-list-create'),
    path('goalsched/<uuid:pk>/', GoalScheduleDetailView.as_view(), name='goalsched-detail'),
    path('deletegoalsched/<int:pk>/', GoalScheduleDeleteView.as_view(), name='goalsched-delete'),
    path('updategoalsched/<int:pk>/',GoalScheduleUpdateView.as_view(), name='updateschedprog' ),
    #sleep log
    path('createsleeplog/', SleepLogListCreateView.as_view(), name='sleeplog-list-create'),
    path('sleeplog/<uuid:pk>/', SleepLogDetailView.as_view(), name='sleeplog-detail'),
    path('deletesleeplog/<int:pk>/', SleepLogDeleteView.as_view(), name='sleeplog-delete'),
    path('updatesleeplog/<int:pk>/', SleepLogUpdateView.as_view(), name='updatesleeplog' ),
]
