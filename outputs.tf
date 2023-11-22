output "iam-arn" {
  value       = aws_iam_policy.enable_mfa.arn
  description = "The ARN assigned by AWS to this policy."
}

output "tags_all" {
  value       = aws_iam_policy.enable_mfa.tags_all
  description = "Additional tags e.g. map(`BusinessUnit`,`XYZ`)"

}