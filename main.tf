module "labels" {
  source      = "cypik/labels/aws"
  version     = "1.0.4"
  name        = var.name
  environment = var.environment
  attributes  = var.attributes
  repository  = var.repository
  managedby   = var.managedby
  label_order = var.label_order
}

data "aws_iam_users" "all_users" {}

data "aws_iam_user" "user_details" {
  for_each  = toset(data.aws_iam_users.all_users.names)
  user_name = each.key
}

data "aws_iam_access_keys" "user_keys" {
  for_each = toset(data.aws_iam_users.all_users.names)
  user     = each.key
}

data "external" "password_last_used" {
  for_each = toset(data.aws_iam_users.all_users.names)

  program = ["${path.module}/scripts/password_last_used.sh"]

  query = {
    user = each.key
  }
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "enable_mfa" {
  statement {
    sid    = "AllowViewAccountInfo"
    effect = "Allow"
    actions = [
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary",
      "iam:ListVirtualMFADevices",
      "iam:ListMFADevices"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowManageOwnPasswords"
    effect = "Allow"
    actions = [
      "iam:ChangePassword",
      "iam:GetUser",
      "iam:CreateLoginProfile",
      "iam:DeleteLoginProfile",
      "iam:GetLoginProfile",
      "iam:UpdateLoginProfile"
    ]
    resources = [
      "arn:aws:iam::*:user/&{aws:username}",
    ]
  }

  statement {
    sid    = "AllowManageOwnAccessKeys"
    effect = "Allow"
    actions = [
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey"

    ]
    resources = [
      "arn:aws:iam::*:user/&{aws:username}",
    ]
  }

  statement {
    sid    = "AllowManageOwnSigningCertificates"
    effect = "Allow"
    actions = [
      "iam:DeleteSigningCertificate",
      "iam:ListSigningCertificates",
      "iam:UpdateSigningCertificate",
      "iam:UploadSigningCertificate",
    ]
    resources = [
      "arn:aws:iam::*:user/&{aws:username}",
    ]
  }

  statement {
    sid    = "AllowManageOwnSSHPublicKeys"
    effect = "Allow"
    actions = [
      "iam:DeleteSSHPublicKey",
      "iam:GetSSHPublicKey",
      "iam:ListSSHPublicKeys",
      "iam:UpdateSSHPublicKey",
      "iam:UploadSSHPublicKey"
    ]
    resources = [
      "arn:aws:iam::*:user/&{aws:username}",
    ]
  }

  statement {
    sid    = "AllowManageOwnGitCredentials"
    effect = "Allow"
    actions = [
      "iam:CreateServiceSpecificCredential",
      "iam:DeleteServiceSpecificCredential",
      "iam:ListServiceSpecificCredentials",
      "iam:ResetServiceSpecificCredential",
      "iam:UpdateServiceSpecificCredential"
    ]
    resources = [
      "arn:aws:iam::*:user/&{aws:username}",
    ]
  }

  statement {
    sid    = "AllowManageOwnVirtualMFADevice"
    effect = "Allow"
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice"
    ]
    resources = [
      "arn:aws:iam::*:user/&{aws:username}",
    ]
  }

  statement {
    sid    = "AllowManageOwnUserMFA"
    effect = "Allow"
    actions = [
      "iam:DeactivateMFADevice",
      "iam:EnableMFADevice",
      "iam:ListMFADevices",
      "iam:ResyncMFADevice"
    ]
    resources = [
      "arn:aws:iam::*:user/&{aws:username}",
    ]
  }

  statement {
    sid    = "DenyAllExceptListedIfNoMFA"
    effect = "Deny"
    not_actions = [
      "iam:CreateVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:GetUser",
      "iam:ListUsers",
      "iam:GetMFADevice",
      "iam:ListMFADevices",
      "iam:ListVirtualMFADevices",
      "iam:ResyncMFADevice",
      "sts:GetSessionToken"
    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["false"]
    }
    condition {
      test     = "Bool"
      variable = "aws:ViaAWSService"
      values   = ["false"]
    }
  }
}

# Create MFA IAM Policy
resource "aws_iam_policy" "enable_mfa" {
  count       = var.mfa_enabled ? 1 : 0
  name        = var.name
  path        = var.path
  description = "Policy to enforce MFA"
  policy      = data.aws_iam_policy_document.enable_mfa.json
}

#tfsec:ignore:aws-iam-enforce-group-mfa
resource "aws_iam_group" "this" {
  for_each = var.mfa_enabled ? toset(var.groups) : toset([])
  name     = each.key
}

resource "aws_iam_group_policy_attachment" "assign_force_mfa_policy_to_groups" {
  for_each   = var.mfa_enabled ? aws_iam_group.this : {}
  group      = each.value.name
  policy_arn = aws_iam_policy.enable_mfa[0].arn
}

resource "aws_iam_group_membership" "group_members" {
  for_each = var.mfa_enabled ? aws_iam_group.this : {}

  name  = "${each.key}-membership"
  group = each.value.name
  users = data.aws_iam_users.all_users.names
}

resource "null_resource" "key_rotation" {
  for_each = var.enable_key_rotation ? toset(data.aws_iam_users.all_users.names) : toset([])

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module

    command = <<EOT
USER=${each.key}
INACTIVE_DAYS=90
OUTPUT_DIR="${path.module}/user_status"
mkdir -p "$OUTPUT_DIR"

PASSWORD_LAST_USED=$(aws iam get-user --user-name "$USER" --query 'User.PasswordLastUsed' --output text 2>/dev/null || echo "Never")

if [ "$PASSWORD_LAST_USED" = "Never" ] || [ "$PASSWORD_LAST_USED" = "None" ]; then
  echo "inactive" > "$OUTPUT_DIR/$USER"
else
  CURRENT_EPOCH=$(date +%s)
  LAST_USED_EPOCH=$(date -d "$PASSWORD_LAST_USED" +%s 2>/dev/null || true)

  if [ -z "$LAST_USED_EPOCH" ]; then
    echo "inactive" > "$OUTPUT_DIR/$USER"
  else
    DAYS_INACTIVE=$(( (CURRENT_EPOCH - LAST_USED_EPOCH) / 86400 ))
    if [ "$DAYS_INACTIVE" -gt "$INACTIVE_DAYS" ]; then
      echo "inactive" > "$OUTPUT_DIR/$USER"
    else
      echo "active" > "$OUTPUT_DIR/$USER"
    fi
  fi
fi
EOT
  }
}

resource "null_resource" "remove_inactive_users" {
  for_each = var.enable_remove_inactive_users ? {
    for user in local.iam_users_list : user => user
  } : {}
  triggers = {
    inactive = contains(local.inactive_users, each.key) ? "true" : "false"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo Removing user ${each.key}"
  }

  lifecycle {
    ignore_changes = [triggers]
  }
}

# Test resource to verify IAM access
resource "null_resource" "test_iam_access" {
  provisioner "local-exec" {
    command     = <<EOT
      echo "Testing IAM access in region: ${var.region}"
      aws iam list-users --region ${var.region} --output json
      echo "Number of users found: $(aws iam list-users --region ${var.region} --query 'Users[].UserName' --output text | wc -w)"
    EOT
    interpreter = ["bash", "-c"]
  }
}

# Get access key last used information via CLI
resource "null_resource" "get_key_last_used" {
  for_each = var.enable_key_rotation ? toset(local.iam_users_list) : toset([])

  provisioner "local-exec" {
    command     = <<EOT
    USER_NAME=${each.key}
    REGION=${var.region}
    echo "Fetching key last used for $USER_NAME in region $REGION"
    aws iam list-access-keys --user-name "$USER_NAME" --region "$REGION" --output json
  EOT
    interpreter = ["bash", "-c"]
  }
}

resource "null_resource" "time_check" {
  provisioner "local-exec" {
    command = <<EOF
      echo "System time: $(date)"
      echo "UTC time: $(date -u)"
      echo "Testing date parsing: $(date -d '2025-08-28T05:06:40Z' +%s)"
    EOF
  }
}

resource "null_resource" "detect_inactive_users" {
  for_each = (var.enable_key_rotation || var.enable_remove_inactive_users) ? toset(data.aws_iam_users.all_users.names) : toset([])

  provisioner "local-exec" {
    command     = <<EOT
      USER=${each.key}
      INACTIVE_DAYS=${var.inactive_days}
      OUTPUT_DIR="${path.root}/user_status"
      mkdir -p "$OUTPUT_DIR"

      # Your detection logic here
    EOT
    interpreter = ["bash", "-c"]
  }
}

resource "null_resource" "remove_inactive_users_final" {
  for_each = var.enable_remove_inactive_users ? { for user in local.inactive_users : user => user } : {}

  triggers = {
    inactive_users = join(",", local.inactive_users)
    timestamp      = timestamp()
  }

  provisioner "local-exec" {
    command     = <<EOT
      # Safety check
      CRITICAL_USERS="admin|root|administrator"
      if echo "${each.key}" | grep -qE "$CRITICAL_USERS"; then
        echo "ERROR: Attempting to delete critical user ${each.key}. Aborting."
        exit 1
      fi

      echo "Removing inactive user: ${each.key}"

      # Remove access keys
      keys=$(aws iam list-access-keys --user-name ${each.key} --query 'AccessKeyMetadata[].AccessKeyId' --output text 2>/dev/null || echo "")
      if [ -n "$keys" ]; then
        for key in $keys; do
          echo "Deleting access key: $key"
          aws iam delete-access-key --user-name ${each.key} --access-key-id $key 2>/dev/null || echo "Warning: Failed to delete key $key"
        done
      fi

      # Remove login profile
      echo "Removing login profile (if exists)"
      aws iam delete-login-profile --user-name ${each.key} 2>/dev/null || echo "No login profile found"

      # Remove from groups
      groups=$(aws iam list-groups-for-user --user-name ${each.key} --query 'Groups[].GroupName' --output text 2>/dev/null || echo "")
      if [ -n "$groups" ]; then
        for group in $groups; do
          echo "Removing from group: $group"
          aws iam remove-user-from-group --user-name ${each.key} --group-name $group 2>/dev/null || echo "Warning: Failed to remove from group $group"
        done
      fi

      # Detach policies
      policies=$(aws iam list-attached-user-policies --user-name ${each.key} --query 'AttachedPolicies[].PolicyArn' --output text 2>/dev/null || echo "")
      if [ -n "$policies" ]; then
        for policy in $policies; do
          echo "Detaching policy: $policy"
          aws iam detach-user-policy --user-name ${each.key} --policy-arn $policy 2>/dev/null || echo "Warning: Failed to detach policy $policy"
        done
      fi

      # Delete user
      echo "Deleting user: ${each.key}"
      aws iam delete-user --user-name ${each.key} && echo "Successfully deleted user: ${each.key}" || echo "Failed to delete user: ${each.key}"
    EOT
    interpreter = ["bash", "-c"]
    environment = {
      AWS_REGION = var.region
    }
  }

  provisioner "local-exec" {
    when        = destroy
    command     = <<EOT
      # Clean up status file
      rm -f "${path.root}/user_status/${each.key}"
      echo "Cleaned up status file for ${each.key}"
    EOT
    interpreter = ["bash", "-c"]
  }

  depends_on = [
    null_resource.detect_inactive_users
  ]
}

resource "null_resource" "track_removed_users" {
  for_each = var.enable_remove_inactive_users ? toset(local.inactive_users) : toset([])

  provisioner "local-exec" {
    command     = <<EOT
      echo "${each.key}" >> "${path.root}/removed_users.txt"
    EOT
    interpreter = ["bash", "-c"]
  }

  depends_on = [null_resource.remove_inactive_users_final]
}

resource "null_resource" "cleanup_status_files" {
  count = var.enable_remove_inactive_users ? 1 : 0

  provisioner "local-exec" {
    command     = <<EOT
      # Get current AWS users
      CURRENT_USERS=$(aws iam list-users --query 'Users[].UserName' --output text 2>/dev/null || echo "")

      # Clean up status files for users that don't exist in AWS
      for status_file in ${path.root}/user_status/*; do
        user_name=$(basename "$status_file")
        if ! echo "$CURRENT_USERS" | grep -q "$user_name"; then
          echo "Removing status file for non-existent user: $user_name"
          rm -f "$status_file"
        fi
      done
    EOT
    interpreter = ["bash", "-c"]
  }

  depends_on = [null_resource.remove_inactive_users_final]
}