#!/usr/bin/env bash
source config.sh

aws ec2 create-key-pair \
--key-name $SSH_KEY_NAME \
--query 'KeyMaterial' --output text > $SSH_PRIVATE_FILE_NAME
 
chmod 600 $SSH_PRIVATE_FILE_NAME

IS_SG_EXISTS=$(aws ec2 describe-security-groups --filters "Name=tag:$SG_TAG_KEY,Values=$SG_TAG_VAL" --query "SecurityGroups[*].{Name:GroupName}" --output text)

if [[ "$IS_SG_EXISTS" == $SG_NAME ]]; then
    echo "Security Group Already Exists, Skipping ..."
    SG_ID=$(aws ec2 describe-security-groups --filters "Name=tag:$SG_TAG_KEY,Values=$SG_TAG_VAL" --query "SecurityGroups[*].{Name:GroupId}" --output text)
else
    echo "Creating Security Group ..."
    SG_ID=$(aws ec2 create-security-group --group-name $SG_NAME --description $SG_DESCRIPTION --tag-specifications "ResourceType=security-group,Tags=[{Key=$SG_TAG_KEY,Value=$SG_TAG_VAL}]"  | jq -r .GroupId)
    aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr '0.0.0.0/0' --output text > /dev/null
fi

aws ec2 run-instances \
--image-id $UBUNTU_X86_ID \
--count 1 \
--instance-type $EC2_TYPE \
--key-name $SSH_KEY_NAME \
--security-group-ids $SG_ID \
--tag-specifications "ResourceType=instance,Tags=[{Key=$EC2_TAG_KEY,Value=$EC2_TAG_VAL}]"
