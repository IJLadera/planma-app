from django.urls import path, include
from .views import TaskListCreateView, TaskRetrieveUpdateDestroyView

urlpatterns = [
    path ('djoser/', include ('djoser.urls')),
    path ('auth/', include ('djoser.urls.jwt')),
    path('tasks/', TaskListCreateView.as_view(), name='task-list-create'),
    path('tasks/<int:pk>/', TaskRetrieveUpdateDestroyView.as_view(), name='task-detail'),
]