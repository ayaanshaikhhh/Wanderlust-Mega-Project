#!/bin/bash
set -euo pipefail

INSTANCE_ID="i-0ec8ae0bc4088b27e"
AWS_REGION="ap-southeast-2"
file_to_find="../frontend/.env.docker"

# Retrieve the worker's public IP
ipv4_address=$(aws ec2 describe-instances \
    --region "$AWS_REGION" \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

# Validate the IP address
if [[ -z "$ipv4_address" || "$ipv4_address" == "None" ]]; then
    echo "ERROR: Could not retrieve the worker's public IP."
    exit 1
fi

# Validate the environment file
if [[ ! -f "$file_to_find" ]]; then
    echo "ERROR: File not found: $file_to_find"
    exit 1
fi

# Update VITE_API_PATH
sed -i "s|^VITE_API_PATH=.*|VITE_API_PATH=\"http://${ipv4_address}:31100\"|" "$file_to_find"

echo "Frontend environment updated successfully."
echo "VITE_API_PATH=http://${ipv4_address}:31100"
