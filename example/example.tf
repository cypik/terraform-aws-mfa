provider "aws" {
  region = "eu-west-2"
}

module "mfa" {
  source      = "./../"
  name        = "mfa"
  environment = "test"
  users       = ["demo"]
  groups      = ["demo-group"]
}

