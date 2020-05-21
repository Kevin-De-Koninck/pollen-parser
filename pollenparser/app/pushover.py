import sys
import http.client
import urllib
from logzero import logger


class Pushover:
    def __init__(self, user_key, project_api_token):
        self.user_key = user_key
        self.project_api_token = project_api_token

    def send_notification(self, message):
        logger.debug("Sending push notification with the following message:\n%s", message)
        conn = http.client.HTTPSConnection("api.pushover.net", port=443, timeout=10)
        conn.request("POST",
                     "/1/messages.json",
                     urllib.parse.urlencode({"token": self.project_api_token,
                                             "user": self.user_key,
                                             "message": message}),
                     {"Content-type": "application/x-www-form-urlencoded"})
        response = conn.getresponse()
        if response.status == 200:
            logger.debug("Successfully sent the push notification.")
        else:
            logger.error("Unable to send a push notification. The full return was:\n%s", repr(response.__dict__))
            sys.exit(1)

