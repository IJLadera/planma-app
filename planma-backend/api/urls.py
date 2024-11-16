from django.urls import path, include
from .views import *

urlpatterns = [
    path ('djoser/', include ('djoser.urls')),
    path ('auth/', include ('djoser.urls.jwt')),
    path('createtask/', CustomTaskListCreateView.as_view(), name='task-list-create'),
    path('tasks/<uuid:pk>/', CustomTaskDetailView.as_view(), name='task-detail'),
    path('deletetask/<int:pk>/', CustomTaskDeleteView.as_view(), name='task-delete'),
    path('updatetask/<int:pk>/',CustomTaskUpdateView.as_view(), name='updatetask' ),
]
