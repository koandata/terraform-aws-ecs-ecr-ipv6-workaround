import boto3
import json
import os


def handler(event, context):
    """
    Retrieves an ECR authorization token and updates a secret in Secrets Manager.
    """

    # Retrieve the SecretId from the environment variable
    secret_id = os.environ["SECRET_ARN"]

    ecr_client = boto3.client("ecr")
    secrets_client = boto3.client("secretsmanager")

    # Get the ECR authorization token
    response = ecr_client.get_authorization_token()
    auth_data = response["authorizationData"][0]
    authorization_token = auth_data["authorizationToken"]

    # Decode the token (it's base64 encoded)
    # awscli does it for you but here it's DIY
    import base64

    username, password = (
        base64.b64decode(authorization_token).decode("utf-8").split(":")
    )

    # Construct the secret value
    secret_value = {
        "username": username,
        "password": password,
    }

    # Update the secret in Secrets Manager
    secrets_client.update_secret(
        SecretId=secret_id, SecretString=json.dumps(secret_value)
    )

    print(f"Successfully updated secret {secret_id}")


if __name__ == "__main__":
    handler(None, None)
