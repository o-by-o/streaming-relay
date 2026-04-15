#!/bin/bash
# Quick deploy script for RTMP relay on AWS EC2
# Usage: ./deploy.sh
#
# Prerequisites:
#   - AWS CLI configured (aws configure)
#   - Key pair created in eu-central-1

set -e

REGION="eu-central-1"
INSTANCE_TYPE="t3.small"
KEY_NAME="rtmp-relay-key"
AMI_ID="ami-018f28221ffaa9b3b"         # Ubuntu 24.04 in eu-central-1

echo "=== Creating Security Group ==="
SG_ID=$(aws ec2 create-security-group \
    --group-name rtmp-relay \
    --description "RTMP relay for streaming" \
    --region "$REGION" \
    --query 'GroupId' --output text)

echo "Security Group: $SG_ID"

# Open SSH
aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --protocol tcp --port 22 \
    --cidr 0.0.0.0/0 \
    --region "$REGION"

# Open RTMP
aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --protocol tcp --port 1935 \
    --cidr 0.0.0.0/0 \
    --region "$REGION"

echo "=== Launching EC2 Instance ==="
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_NAME" \
    --security-group-ids "$SG_ID" \
    --user-data file://user-data.sh \
    --region "$REGION" \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=rtmp-relay}]' \
    --query 'Instances[0].InstanceId' --output text)

echo "Instance: $INSTANCE_ID"
echo "Waiting for instance to be running..."

aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --region "$REGION"

PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --region "$REGION" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

echo ""
echo "=== READY ==="
echo "Instance ID:  $INSTANCE_ID"
echo "Public IP:    $PUBLIC_IP"
echo ""
echo "OBS settings:"
echo "  Server:     rtmp://$PUBLIC_IP/live"
echo "  Stream key: stream"
echo ""
echo "SSH:          ssh -i ~/.ssh/${KEY_NAME}.pem ubuntu@$PUBLIC_IP"
echo ""
echo "To stop (save money):"
echo "  aws ec2 stop-instances --instance-ids $INSTANCE_ID --region $REGION"
echo ""
echo "To start again:"
echo "  aws ec2 start-instances --instance-ids $INSTANCE_ID --region $REGION"
