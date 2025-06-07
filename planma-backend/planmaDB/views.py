from django.http import JsonResponse
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync

def trigger_reminder(request):
    message = request.GET.get('message', '🕐 Reminder from Postman!')

    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)(
        "reminders",
        {
            "type": "send_notification",
            "message": message
        }
    )

    return JsonResponse({"status": "Notification sent", "message": message})
