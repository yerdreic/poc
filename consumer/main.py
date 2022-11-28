#!/usr/bin/env python3

import json

import boto3
from botocore.exceptions import ClientError


def main():

    secret_name = "poc"
    region_name = "eu-west-2"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name="secretsmanager", region_name=region_name
    )

    index = 0
    while True:
        try:
            get_secret_value_response = client.get_secret_value(
                SecretId=secret_name
            )
        except ClientError as e:
            raise e

        secret = json.loads(get_secret_value_response["SecretString"])
        for key, value in secret.items():
            print(f"{index}: {key} {value}", flush=True)
        index += 1


if __name__ == "__main__":
    main()
