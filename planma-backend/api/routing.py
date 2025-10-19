from django.urls import re_path
from planmaDB import consumers

websocket_urlpatterns = [
    re_path(r"ws/reminders/(?P<student_id>[\w-]+)/$", consumers.ReminderConsumer.as_asgi()),
]
