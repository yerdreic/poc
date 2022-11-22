#!/usr/bin/env bash
source config.sh

aws ec2 delete-key-pair --key-name $SSH_KEY_NAME

EC2_INSTANCE_ID=$(aws --region=$AWS_REGION ec2 describe-instances --filters "Name=tag:$EC2_TAG_KEY,Values=$EC2_TAG_VAL" --query 'Reservations[*].Instances[*].{Instance:InstanceId}' --output text)

if [[ -n $EC2_INSTANCE_ID ]]; then
    aws ec2 terminate-instances --instance-ids $EC2_INSTANCE_ID
fi
