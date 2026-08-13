output "iam_arn" {
  value       = module.mfa.iam_arn
  description = "The ARN assigned by AWS to this policy."
}

output "tags" {
  value       = module.mfa.tags_all
  description = "Additional tags e.g. map(`BusinessUnit`,`XYZ`)"
}

output "active_users" {
  description = "List of active IAM users"
  value       = module.mfa.active_users
}

output "all_iam_users" {
  description = "All IAM users in the account"
  value       = module.mfa.all_iam_users
}

output "inactive_users_to_remove" {
  description = "List of inactive users that will be removed"
  value       = module.mfa.inactive_users_to_remove
}

output "user_last_access_dates" {
  description = "Last access dates for all users with password and key usage information"
  value       = module.mfa.user_last_access_dates
}

output "users_needing_rotation" {
  description = "Users who need access key rotation"
  value       = module.mfa.users_needing_rotation
}

output "user_ages" {
  description = "Age of each IAM user in days"
  value       = module.mfa.user_ages
}

output "key_ages" {
  description = "Age information for all access keys"
  value       = module.mfa.key_ages
}

output "key_age_info" {
  description = "Formatted key age information"
  value       = module.mfa.key_age_info
}

output "inactive_user_ages" {
  description = "Age of inactive users in days"
  value       = module.mfa.inactive_user_ages
}

output "rotation_summary" {
  description = "Summary of key rotation activities"
  value       = module.mfa.rotation_summary
}




