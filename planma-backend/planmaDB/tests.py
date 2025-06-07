# myapp/tests.py
from django.test import TestCase
from channels.testing import WebsocketCommunicator
from myproject.asgi import application
import asyncio

class WebSocketTests(TestCase):
    async def test_websocket_send_receive(self):
        # Create a WebSocket communicator
        communicator = WebsocketCommunicator(application, "/ws/reminders/")
        
        # Test connection
        connected, subprotocol = await communicator.connect()
        self.assertTrue(connected, "WebSocket connection failed")

        # Test sending a message
        test_message = {"message": "Test reminder"}
        await communicator.send_json_to(test_message)
        
        # Since we're just testing send/receive, we won't wait for the scheduled reminder
        # Instead, let's verify the connection works by sending a manual message back
        await communicator.send_json_to({"message": "Echo test"})
        response = await communicator.receive_json_from(timeout=2)
        self.assertEqual(response["message"], "Echo test", "Message echo failed")

        # Cleanup
        await communicator.disconnect()

    def test_sync_wrapper(self):
        # Synchronous wrapper for running the async test
        asyncio.run(self.test_websocket_send_receive())