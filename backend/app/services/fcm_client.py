from __future__ import annotations

from firebase_admin import messaging

class FCMClient:
    def send(self, token: str, data: dict[str, str]) -> str:
        message = messaging.Message(token=token, data=data)
        response = messaging.send(message)
        return response
