#!/bin/bash
set -e

user_name=$1
region=$2

echo "Getting key last used information for user: $user_name"

# Get access key last used information
keys=$(aws iam list-access-keys --user-name "$user_name" --query 'AccessKeyMetadata[].AccessKeyId' --output text --region "$region" 2>/dev/null || echo "")

if [ -n "$keys" ]; then
  for key in $keys; do
    last_used=$(aws iam get-access-key-last-used --access-key-id "$key" --query 'AccessKeyLastUsed.LastUsedDate' --output text --region "$region" 2>/dev/null || echo "Never")
    echo "Key $key last used: $last_used"
  done
else
  echo "No access keys found for user: $user_name"
fi