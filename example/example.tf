provider "aws" {
  region = "eu-west-2"
}

module "mfa" {
  source                       = "./../"
  name                         = "mfa"
  environment                  = "test"
  inactive_days                = 1
  key_rotation_days            = 1
  mfa_enabled                  = true
  enable_key_rotation          = true
  enable_remove_inactive_users = true
}
