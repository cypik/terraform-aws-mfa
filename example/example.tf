provider "aws" {
  region = "eu-west-1"
}
module "mfa" {
  source      = "../"
  name        = "mfa1"
  environment = "test"
  users       = []
  groups      = []

}

