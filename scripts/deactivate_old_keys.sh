#!/bin/bash
set -e

user_name=$1
region=$2

echo "Deactivating old keys for user: $user_name"

# Get all access keys for the user
keys=$(aws iam list-access-keys --user-name "$user_name" --query 'AccessKeyMetadata[].AccessKeyId' --output text --region "$region" 2>/dev/null || echo "")

if [ -n "$keys" ]; then
  for key in $keys; do
    echo "Deactivating key: $key for user: $user_name"
    aws iam update-access-key --user-name "$user_name" --access-key-id "$key" --status Inactive --region "$region"
  done
  echo "All old keys deactivated for user: $user_name"
else
  echo "No access keys found for user: $user_name"
fi