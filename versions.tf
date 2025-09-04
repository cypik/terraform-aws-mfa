# Terraform version
terraform {
  required_version = ">= 1.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.11.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.4"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3.5"
    }
  }
}