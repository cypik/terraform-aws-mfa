# Terraform-aws-mfa

# AWS Infrastructure Provisioning with Terraform

## Table of Contents
- [Introduction](#introduction)
- [Usage](#usage)
- [Module Inputs](#module-inputs)
- [Module Outputs](#module-outputs)
- [License](#license)

## Introduction
This module is basically combination of Terraform open source and includes automatation tests and examples. It also helps to create and improve your infrastructure with minimalistic code instead of maintaining the whole infrastructure code yourself.
## Usage
To use this module, you can include it in your Terraform configuration. Here's an example of how to use it:

## Example

```hcl
module "mfa" {
  source      = "git::https://github.com/cypik/terraform-aws-mfa.git?ref=v1.0.0"
  name        = "mfa"
  environment = "test"
  users       = []
  groups      = []

}
```

## Module Inputs
- `name`: A name for your application.
- `environment`: The environment for your application.
- For security group settings, you can configure the ingress and egress rules using variables like:
## Module Outputs
- `arn` : The Amazon Resource Name (ARN) specifying the virtual mfa device.
- `tags`:  Map of resource tags for the virtual mfa device.
- Other relevant security group outputs (modify as needed).

## Example
For detailed examples on how to use this module, please refer to the 'examples' directory within this repository.

## Author
Your Name Replace '[License Name]' and '[Your Name]' with the appropriate license and your information. Feel free to expand this README with additional details or usage instructions as needed for your specific use case.

## License
This project is licensed under the MIT License - see the [LICENSE](https://github.com/cypik/terraform-aws-mfa/blob/master/LICENSE) file for details.
