import json 
from channels.generic.websocket import AsyncWebsocketConsumer
from django.utils import timezone
from django.utils.timezone import now
import asyncio
from datetime import timedelta
from channels.db import database_sync_to_async
from api.utilities import get_sleep_reminders
import redis

r = redis.Redis()

class ReminderConsumer(AsyncWebsocketConsumer):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._reminder_task = None  # Store task reference

    async def connect(self):
        # print(self.scope['url_route']['kwargs']['student_id'])
        self.student_id = self.scope['url_route']['kwargs']['student_id']
        self.room_group_name = f"user_{self.student_id}"

        # On connect, assume foreground
        await self.set_foreground_status(True)

        # Join room group
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )

        await self.accept()
        # Start the periodic reminder task and store it
        self._reminder_task = asyncio.create_task(self.periodic_reminder_check())
    
    async def disconnect(self, close_code):
        await self.set_foreground_status(False)
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )

        if self._reminder_task:
            self._reminder_task.cancel()
            try:
                await self._reminder_task
            except asyncio.CancelledError:
                print(f"[WS] Cancelled periodic task for {self.student_id}")

    # Receive message from WebSocket (from client)
    async def receive(self, text_data):
        text_data_json = json.loads(text_data)
        message_type = text_data_json.get('type')

        # Refresh TTL and update foreground/background state
        if message_type == 'status_update':
            foreground = text_data_json.get('foreground', False)
            await self.set_foreground_status(foreground)
            print(f"[WS] Foreground status updated for {self.student_id}: {foreground}")
        elif message_type == 'check_reminders':
            await self.check_reminders()

    async def set_foreground_status(self, foreground: bool):
        key = f"user_online:{self.student_id}"
        if foreground:
            r.set(key, json.dumps({
                    "last_seen": now().isoformat(),
                    "foreground": True
            }), ex=300)
        else:
            r.delete(key)

    # Send reminder to WebSocket
    async def reminder_notification(self, event):
        reminder_type = event['reminder_type']
        reminder = event['reminder']

        # Send message to WebSocket
        await self.send(
            text_data=json.dumps({
                'type': 'reminder',
                'reminder_type': reminder_type,
                'reminder': reminder
            })
        )
    
    # Periodic check for reminders
    async def periodic_reminder_check(self):
        while True:
            try:
                start = timezone.now()
                await self.set_foreground_status(True)
                print(f"[WS] TTL/foreground refreshed for {self.student_id}")
                await self.check_reminders()

                # Calculate time taken and adjust sleep to keep interval consistent
                elapsed = (timezone.now() - start).total_seconds()
                await asyncio.sleep(max(60 - elapsed, 0))
            except asyncio.CancelledError:
                print(f"[WS] Stopping reminder loop for {self.student_id}")
                break

    async def check_reminders(self):
        # Check all reminder types
        await self.check_sleep_reminders()
    
    @database_sync_to_async
    def check_sleep_reminders(self):
        return [
                {
                    'sleep_time': "7:10PM",
                    'message': "Time to prepare for sleep soon!"
                }
            ]
        # return get_sleep_reminders(self.student_id)


    # Receive message from room group
    """ async def reminder_message(self, event):
        message = event['message']

        # Send message to WebSocket
        await self.send(text_data=json.dumps({
            'type': 'reminder',
            'message': "Wake UP!"
        })) """