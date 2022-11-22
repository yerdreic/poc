# Requiremnts - an aws cli is required to run this script
# In order to install the aws cli, visit - https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

aws ec2 create-key-pair \
--key-name poc-aws-key \
--query 'KeyMaterial' --output text > ~/.ssh/poc-aws-key

aws ec2 run-instances \
--image-id ami-0caef02b518350c8b \
--count 1 \
--instance-type t2.micro \
--key-name poc-aws-key \
--security-group-ids sg-048e847f082a240c0 \
--subnet-id subnet-ee9618a2 \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=poc-aws-server}]' 