import os
import json
import boto3

SES_REGION = os.environ.get("SES_REGION", "eu-north-1")
SES_FROM_EMAIL = os.environ["SES_FROM_EMAIL"]
SES_TO_EMAILS = os.environ["SES_TO_EMAILS"].split(",")

ses = boto3.client("ses", region_name=SES_REGION)

def lambda_handler(event, context):
    try:
        sns_message = json.loads(event["Records"][0]["Sns"]["Message"])

        alarm_name = sns_message.get("AlarmName", "Unknown Alarm")
        alarm_description = sns_message.get("AlarmDescription", "")
        new_state = sns_message.get("NewStateValue", "")
        reason = sns_message.get("NewStateReason", "")

        subject = f"CloudWatch Alarm Triggered: {alarm_name}"
        body_text = (
            f"Alarm: {alarm_name}\n"
            f"State: {new_state}\n"
            f"Description: {alarm_description}\n"
            f"Reason: {reason}\n"
        )

        ses.send_email(
            Source=SES_FROM_EMAIL,
            Destination={"ToAddresses": SES_TO_EMAILS},
            Message={
                "Subject": {"Data": subject, "Charset": "UTF-8"},
                "Body": {
                    "Text": {"Data": body_text, "Charset": "UTF-8"}
                },
            },
        )

        return {"statusCode": 200, "body": "Email sent successfully"}

    except Exception as e:
        print(f"Error sending SES email: {str(e)}")
        return {"statusCode": 500, "body": str(e)}
