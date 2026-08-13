variable "name" {
  type        = string
  description = "Name  (e.g. `test` or `mfa`)."
}
variable "path" {
  type        = string
  default     = "/"
  description = "The path of the policy in MFA."
}

variable "attributes" {
  type        = list(any)
  default     = []
  description = "Additional attributes (e.g. `1`)."
}

variable "repository" {
  type        = string
  default     = "https://github.com/cypik/terraform-aws-mfa"
  description = "Terraform current module repo"
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list(any)
  default     = ["name", "environment"]
  description = "Label order, e.g. `name`,`application`."
}

variable "managedby" {
  type        = string
  default     = "info@cypik.com"
  description = "ManagedBy, eg 'info@cypik.com'."
}

variable "groups" {
  type        = list(string)
  default     = ["mfa-required"]
  description = "enable MFA for the members in these groups"
}

variable "mfa_enabled" {
  type        = bool
  default     = true
  description = "Enable or disable MFA enforcement"
}

variable "region" {
  type        = string
  default     = ""
  description = "AWS region"
}

variable "inactive_days" {
  type        = number
  default     = 90
  description = "Number of days after which inactive users are deleted"
}

variable "key_rotation_days" {
  type        = number
  default     = 90
  description = "Number of days after which access keys should be rotated"
}

variable "iam_users" {
  type        = list(string)
  default     = []
  description = "List of IAM users to manage"
}

variable "enable_key_rotation" {
  type        = bool
  default     = false
  description = "Enable or disable key rotation logic"
}

variable "enable_remove_inactive_users" {
  type        = bool
  default     = false
  description = "Enable or disable inactive user removal logic"
}