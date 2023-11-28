
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
  default     = ""
  description = "Terraform current module repo"
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list(any)
  default     = []
  description = "label order, e.g. `name`,`application`."
}

variable "managedby" {
  type        = string
  default     = ""
  description = "ManagedBy, eg 'cypik'."
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

