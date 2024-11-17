from django.urls import path, include
from .views import *

urlpatterns = [
    path ('djoser/', include ('djoser.urls')),
    path ('auth/', include ('djoser.urls.jwt')),
    #tasks
    path('createtask/', CustomTaskListCreateView.as_view(), name='task-list-create'),
    path('tasks/<uuid:pk>/', CustomTaskDetailView.as_view(), name='task-detail'),
    path('deletetask/<int:pk>/', CustomTaskDeleteView.as_view(), name='task-delete'),
    path('updatetask/<int:pk>/',CustomTaskUpdateView.as_view(), name='updatetask' ),
    #events
    path('createevents/', CustomEventListCreateView.as_view(), name='event-list-create'),
    path('events/<uuid:pk>/', CustomEventDetailView.as_view(), name='event-detail'),
    path('deleteevents/<int:pk>/', CustomEventDeleteView.as_view(), name='event-delete'),
    path('updateevent/<int:pk>/',CustomEventUpdateView.as_view(), name='updateevent' ),
    #attended event
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
    #class
    path('createclass/', CustomClassListCreateView.as_view(), name='class-list-create'),
    path('classes/<uuid:pk>/', CustomClassDetailView.as_view(), name='class-detail'),
    path('deleteclass/<int:pk>/', CustomClassDeleteView.as_view(), name='class-delete'),
    path('updateclass/<int:pk>/',CustomClassUpdateView.as_view(), name='updateclass' ),
    #excused class
    path('createclassexc/', ExcClassListCreateView.as_view(), name='excclass-list-create'),
    path('userclassexc/<uuid:pk>/', ExcClassDetailView.as_view(), name='excclass-detail'),
    path('deleteclassexc/<int:pk>/', ExcClassDeleteView.as_view(), name='excclass-delete'),
    path('updateclassexc/<int:pk>/',ExcClassUpdateView.as_view(), name='updateexcclass' ),
    #attended class
    path('createclassatt/', AttClassListCreateView.as_view(), name='attclass-list-create'),
    path('userclassatt/<uuid:pk>/', AttClassDetailView.as_view(), name='attclass-detail'),
    path('deleteclassatt/<int:pk>/', AttClassDeleteView.as_view(), name='attclass-delete'),
    path('updateclassatt/<int:pk>/',AttClassUpdateView.as_view(), name='updateattclass' ),
]
