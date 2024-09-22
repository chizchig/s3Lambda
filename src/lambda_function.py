import json
import urllib.parse
import boto3

print('Loading function')

s3 = boto3.client('s3')
sns = boto3.client('sns')

def lambda_handler(event, context):
    # print("Received event:" + json.dumps(event, indent=2))

    # Get the object from the event
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    eventname = event['Records'][0]['eventName']
    sns_message = ""

    try:
        print(f"Event: {eventname}")
        if eventname.startswith("ObjectRemoved:"):
            print("File is being Deleted")
            sns_message = f"File {key} was deleted from bucket {bucket}"
        elif eventname.startswith("ObjectCreated:"):
            response = s3.get_object(Bucket=bucket, Key=key)
            content_type = response['ContentType']
            sns_message = f"File {key} was added to bucket {bucket}\nContent Type: {content_type}"
            print(f"CONTENT TYPE: {content_type}")
        else:
            sns_message = f"Unhandled event {eventname} occurred on file {key} in bucket {bucket}"

        print(sns_message)
        subject = f"S3 Bucket[{bucket}] Event[{eventname}]"
        print(subject)
        
        sns_response = sns.publish(
            TargetArn='<REPLACE THIS WITH YOUR SNS ARN>',
            Message=sns_message,
            Subject=subject
        )
        print(f"SNS publish response: {sns_response}")
        
        return {
            'statusCode': 200,
            'body': json.dumps('Function executed successfully')
        }
    except Exception as e:
        print(e)
        print(f'Error processing object {key} from bucket {bucket}. Make sure they exist and your bucket is in the same region as this function.')
        raise e