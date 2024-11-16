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
]
