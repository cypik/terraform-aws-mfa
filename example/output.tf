output "iam-arn" {
  value       = module.mfa.iam-arn
  description = "The ARN assigned by AWS to this policy."

}

output "tags" {
  value       = module.mfa.tags_all
  description = "Additional tags e.g. map(`BusinessUnit`,`XYZ`)"
}