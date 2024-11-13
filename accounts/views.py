from rest_framework.response import Response
from rest_framework.views import APIView
from .models import CustomTask
from .serializers import CreateTaskSerializer
from rest_framework import generics
from rest_framework import status


class TaskListCreateView(generics.ListCreateAPIView):
    queryset = CustomTask.objects.all()
    serializer_class = CreateTaskSerializer


class TaskRetrieveUpdateDestroyView(generics.RetrieveUpdateDestroyAPIView):
    queryset = CustomTask.objects.all()
    serializer_class = CreateTaskSerializer
    lookup_field = 'pk'