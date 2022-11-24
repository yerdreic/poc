#!/usr/bin/env bash

set -euo pipefail

source config.sh

IS_POLICY_EXIST=$(aws iam list-policies --query "Policies[?PolicyName==$POLICY_NAME]" --output text)

if [[ -n $IS_POLICY_EXIST ]]; then
    aws iam create-policy --policy-name $POLICY_NAME --policy-document file://assets/policy.json
fi

IS_IAM_ROLE_EXIST=$(aws iam list-roles --query 'Roles[*].RoleName' --output text | grep $IAM_ROLE_NAME)

if [[ -n $IS_IAM_ROLE_EXIST ]]; then
    echo "IAM Role already Exists, Skipping ..."
else
    echo "Creating IAM Role ..."
    aws iam create-role --role-name $IAM_ROLE_NAME --assume-role-policy-document file://assets/iam_role.json > /dev/null
    echo "Adding policy to IAM Role ..."
    aws iam put-role-policy --role-name $IAM_ROLE_NAME --policy-name $POLICY_NAME --policy-document file://assets/policy.json > /dev/null
    echo "Creating Instance Profile ..."
    aws iam create-instance-profile --instance-profile-name $PROFILE_NAME  > /dev/null
    echo "Adding Role to Instance Profile ..."
    aws iam add-role-to-instance-profile --instance-profile-name $PROFILE_NAME --role-name $IAM_ROLE_NAME > /dev/null
fi

IS_SSH_EXIST=$(aws ec2 describe-key-pairs --filters "Name=key-name,Values=$SSH_KEY_NAME" --output text)

if [[ -n $IS_SSH_EXIST ]]; then
    echo "SSH key Already Exists, Skipping ..."
else
    echo "Creating SSH key-pair..."
    aws ec2 create-key-pair --key-name $SSH_KEY_NAME --query 'KeyMaterial' --output text > $SSH_PRIVATE_FILE_NAME
    chmod 400 $SSH_PRIVATE_FILE_NAME
fi


IS_SG_EXIST=$(aws ec2 describe-security-groups --filters "Name=tag:$SG_TAG_KEY,Values=$SG_TAG_VAL" --query "SecurityGroups[*].{Name:GroupName}" --output text)

if [[ "$IS_SG_EXIST" == $SG_NAME ]]; then
    echo "Security Group Already Exists, Skipping ..."
    SG_ID=$(aws ec2 describe-security-groups --filters "Name=tag:$SG_TAG_KEY,Values=$SG_TAG_VAL" --query "SecurityGroups[*].{Name:GroupId}" --output text)
else
    echo "Creating Security Group ..."
    SG_ID=$(aws ec2 create-security-group --group-name $SG_NAME --description "$SG_DESCRIPTION" --tag-specifications "ResourceType=security-group,Tags=[{Key=$SG_TAG_KEY,Value=$SG_TAG_VAL}]"  | jq -r .GroupId)
    aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr '0.0.0.0/0' --output text > /dev/null
fi

aws ec2 run-instances \
--image-id $UBUNTU_X86_ID \
--count 1 \
--instance-type $EC2_TYPE \
--key-name $SSH_KEY_NAME \
--security-group-ids $SG_ID \
--iam-instance-profile Name=$PROFILE_NAME \
--tag-specifications "ResourceType=instance,Tags=[{Key=$EC2_TAG_KEY,Value=$EC2_TAG_VAL}]" > /dev/null
