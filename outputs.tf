output "iam_arn" {
  value       = length(aws_iam_policy.enable_mfa) > 0 ? aws_iam_policy.enable_mfa[0].arn : null
  description = "The ARN assigned by AWS to this policy."
}

output "tags_all" {
  value       = length(aws_iam_policy.enable_mfa) > 0 ? aws_iam_policy.enable_mfa[0].tags_all : {}
  description = "Additional tags e.g. map(`BusinessUnit`,`XYZ`)"
}

output "active_users" {
  value       = local.active_users
  description = "List of active IAM users"
}

output "users_with_keys" {
  value       = local.iam_users_list
  description = "List of users who have access keys"
}

output "all_iam_users" {
  value       = local.iam_users_list
  description = "All IAM users in the account"
}

output "inactive_users_to_remove" {
  value       = local.inactive_users
  description = "List of inactive users that will be removed"
}

output "user_last_access_dates" {
  value       = local.user_access_info
  description = "Last access dates for all users"
}

output "users_needing_rotation" {
  value       = local.users_needing_rotation
  description = "Users who need access key rotation"
}

output "user_ages" {
  value       = local.user_ages
  description = "Age of each IAM user in days"
}

output "key_ages" {
  value       = local.key_ages
  description = "Age information for all access keys"
}

output "key_age_info" {
  value       = local.key_age_info
  description = "Formatted key age information"
}

output "inactive_user_ages" {
  value       = { for user in local.inactive_users : user => local.user_ages[user] }
  description = "Age of inactive users in days"
}

output "rotation_summary" {
  value       = <<EOT
Key Rotation Summary:
- Users needing rotation: ${length(local.users_needing_rotation)}
- Inactive users to remove: ${length(local.inactive_users)}
- Total users: ${length(local.iam_users_list)}
- Default rotation period: ${var.key_rotation_days} days
- Default inactivity period: ${var.inactive_days} days
EOT
  description = "Summary of key rotation activities"
}

output "debug_user_attributes" {
  value = {
    for user_name in local.iam_users_list :
    user_name => {
      available_attributes = keys(data.aws_iam_user.user_details[user_name])
    }
  }
}

output "debug_key_dates" {
  value = {
    for user_name in local.iam_users_list :
    user_name => [
      for key in data.aws_iam_access_keys.user_keys[user_name].access_keys : {
        access_key_id = key.access_key_id
        create_date   = key.create_date
        status        = key.status
      }
    ]
  }
  description = "Debug information for key dates"
}

output "current_timestamp" {
  value       = timestamp()
  description = "Current timestamp for debugging"
}

output "user_inactivity_status" {
  value = { for user_name in local.iam_users_list :
    user_name => {
      last_used     = local.user_last_used_info[user_name].password_last_used
      days_inactive = local.user_ages[user_name]
      is_inactive   = local.user_is_inactive[user_name]
    }
  }
}

output "inactivity_threshold" {
  value       = var.inactive_days
  description = "Current inactivity threshold in days"
}

output "removal_summary" {
  value       = <<EOT
User Removal Summary:
- Inactive users to remove: ${length(local.inactive_users)}
- Inactivity threshold: ${var.inactive_days} days
- Total users in account: ${length(local.iam_users_list)}
EOT
  description = "Summary of user removal activities"
}

output "password_last_used_info" {
  value = { for user_name in local.iam_users_list :
    user_name => local.user_last_used_info[user_name].password_last_used
  }
}

output "user_removal_status" {
  value = {
    inactive_users_detected     = local.inactive_users
    users_scheduled_for_removal = [for user in local.inactive_users : user]
    total_users_managed         = length(var.iam_users)
    removal_timestamp           = timestamp()
  }
  description = "Status of user removal operations"
}

output "removal_execution_plan" {
  value       = <<EOT
User Removal Execution Plan:
- Inactive users detected: ${length(local.inactive_users)}
- Users to be removed: ${join(", ", local.inactive_users)}
- Total managed users: ${length(var.iam_users)}
- Execution will proceed in this order:
  1. Deactivate access keys
  2. Remove login profiles
  3. Remove group memberships
  4. Detach policies
  5. Delete users
EOT
  description = "Plan for user removal execution"
}