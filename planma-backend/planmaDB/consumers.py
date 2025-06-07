import json 
from channels.generic.websocket import AsyncWebsocketConsumer
from django.utils import timezone
import asyncio
from datetime import timedelta
from channels.db import database_sync_to_async
from api.utilities import get_sleep_reminders

class ReminderConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        # print(self.scope['url_route']['kwargs']['student_id'])
        self.student_id = self.scope['url_route']['kwargs']['student_id']
        self.room_group_name = f"user_{self.student_id}"

        # Join room group
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )

        await self.accept()

        # Start background task to check for reminders periodically
        asyncio.create_task(self.periodic_reminder_check())
    
    async def disconnect(self, close_code):
        # Leave room group
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )

    # Receive message from WebSocket (from client)
    async def receive(self, text_data):
        text_data_json = json.loads(text_data)
        message_type = text_data_json.get('type')

        if message_type == 'check_reminders':
            await self.check_reminders()


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
            await self.check_reminders()
            # Check every 60 seconds
            await asyncio.sleep(60)

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