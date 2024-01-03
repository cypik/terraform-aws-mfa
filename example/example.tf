provider "aws" {
  region = "eu-west-1"
}
module "mfa" {
  source      = "./../"
  name        = "mfa"
  environment = "test"
  users       = ["demo"]
  groups      = ["demo-group"]
}

