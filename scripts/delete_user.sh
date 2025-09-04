#!/bin/bash
set -e

user_name="$1"
region="$2"
inactive_days="$3"

echo "Processing user: $user_name (inactive for more than $inactive_days days)"

# Get password last used information
password_last_used=$(aws iam get-user --user-name "$user_name" --query 'User.PasswordLastUsed' --output text --region "$region" 2>/dev/null || echo "Never")

if [ "$password_last_used" != "Never" ] && [ "$password_last_used" != "None" ]; then
  # Calculate actual inactivity period
  current_epoch=$(date +%s)
  last_used_epoch=$(date -d "$password_last_used" +%s)
  days_inactive=$(( (current_epoch - last_used_epoch) / 86400 ))

  echo "User $user_name was last active $days_inactive days ago (threshold: $inactive_days days)"

  if [ "$days_inactive" -lt "$inactive_days" ]; then
    echo "User $user_name is not beyond the inactivity threshold, skipping removal"
    exit 0
  fi
else
  echo "User $user_name has never used password or no data available"
  # For never-used accounts, we'll proceed with deletion
fi

# Remove access keys
access_keys=$(aws iam list-access-keys --user-name "$user_name" --query 'AccessKeyMetadata[].AccessKeyId' --output text --region "$region" 2>/dev/null || echo "")
if [ -n "$access_keys" ]; then
  for key in $access_keys; do
    echo "Deleting access key: $key"
    aws iam delete-access-key --user-name "$user_name" --access-key-id "$key" --region "$region" 2>/dev/null || echo "Warning: Failed to delete access key $key"
  done
fi

# Remove login profile
echo "Checking for login profile..."
if aws iam delete-login-profile --user-name "$user_name" --region "$region" 2>/dev/null; then
  echo "Deleted login profile"
else
  echo "No login profile found"
fi

# Remove user from groups
groups=$(aws iam list-groups-for-user --user-name "$user_name" --query 'Groups[].GroupName' --output text --region "$region" 2>/dev/null || echo "")
if [ -n "$groups" ]; then
  for group in $groups; do
    echo "Removing user from group: $group"
    aws iam remove-user-from-group --user-name "$user_name" --group-name "$group" --region "$region" 2>/dev/null || echo "Warning: Failed to remove user from group $group"
  done
fi

# Remove attached policies
policies=$(aws iam list-attached-user-policies --user-name "$user_name" --query 'AttachedPolicies[].PolicyArn' --output text --region "$region" 2>/dev/null || echo "")
if [ -n "$policies" ]; then
  for policy in $policies; do
    echo "Detaching policy: $policy"
    aws iam detach-user-policy --user-name "$user_name" --policy-arn "$policy" --region "$region" 2>/dev/null || echo "Warning: Failed to detach policy $policy"
  done
fi

# Remove inline policies
inline_policies=$(aws iam list-user-policies --user-name "$user_name" --query 'PolicyNames' --output text --region "$region" 2>/dev/null || echo "")
if [ -n "$inline_policies" ]; then
  for policy in $inline_policies; do
    echo "Deleting inline policy: $policy"
    aws iam delete-user-policy --user-name "$user_name" --policy-name "$policy" --region "$region" 2>/dev/null || echo "Warning: Failed to delete inline policy $policy"
  done
fi

# Finally, delete the user
echo "Deleting user: $user_name"
if aws iam delete-user --user-name "$user_name" --region "$region"; then
  echo "Successfully deleted user: $user_name"
else
  echo "Failed to delete user $user_name"
  exit 1
fi
