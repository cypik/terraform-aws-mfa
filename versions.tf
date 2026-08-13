# Terraform version
terraform {
  required_version = ">= 1.15.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.58.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.3.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.4.0"
    }
  }
}