import os
from slack_sdk import WebClient
from slack_sdk.errors import SlackApiError

# Load your Slack Bot Token
SLACK_BOT_TOKEN = ""

client = WebClient(token=SLACK_BOT_TOKEN)

def send_test_message(channel, text):
    try:
        response = client.chat_postMessage(
            channel=channel,
            text=text
        )
        print("Message sent:", response["ts"])
    except SlackApiError as e:
        print(f"Error sending message: {e.response['error']}")

# Test sending a message (Replace '#general' with your channel name)
send_test_message("#general", "Hello, ChatOps bot is live! 🚀")
 