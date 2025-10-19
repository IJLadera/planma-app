# api/routing.py
from django.urls import re_path
from .consumers import ReminderConsumer 

websocket_urlpatterns = [
    # re_path(r'ws/reminders/$', ReminderConsumer.as_asgi()),
    re_path(r'ws/reminders/(?P<student_id>[\w-]+)/$', ReminderConsumer.as_asgi()),
]
