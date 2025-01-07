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
  default     = []
  description = "enable MFA for the members in these groups"
}

variable "users" {
  type        = list(string)
  default     = []
  description = "enable MFA for these users"
}

