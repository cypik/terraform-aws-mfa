provider "aws" {
  region = "us-east-2"
}

module "mfa" {
  source      = "./../"
  name        = "mfa"
  environment = "test"
  users       = ["demo"]
  groups      = ["demo-group"]
}

