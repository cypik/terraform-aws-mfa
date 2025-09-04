#!/usr/bin/env bash
set -e

# Read JSON input from Terraform (whole line)
if ! read -r input; then
  echo '{"password_last_used":"Never"}'
  exit 0
fi

# Extract user field safely
USER=$(echo "$input" | jq -r '.user // empty')

if [ -z "$USER" ]; then
  echo '{"password_last_used":"Never"}'
  exit 0
fi

# Get password last used via AWS CLI
PASSWORD_LAST_USED=$(aws iam get-user --user-name "$USER" --query 'User.PasswordLastUsed' --output text 2>/dev/null || echo "Never")

if [ "$PASSWORD_LAST_USED" == "None" ] || [ -z "$PASSWORD_LAST_USED" ]; then
  PASSWORD_LAST_USED="Never"
fi

# Always return valid JSON
echo "{\"password_last_used\": \"$PASSWORD_LAST_USED\"}"
