# Terraform-aws-mfa

# Terraform AWS Cloud MFA Module

## Table of Contents
- [Introduction](#introduction)
- [Usage](#usage)
- [Example](#Example)
- [Author](#Author)
- [License](#license)
- [Inputs](#inputs)
- [Outputs](#outputs)

## Introduction
This Terraform module creates an AWS Multi-Factor Authentication (MFA) along with additional configuration options.

## Usage
To use this module, you can include it in your Terraform configuration. Here's an example of how to use it:

## Example

```hcl
module "mfa" {
  source                       = "cypik/mfa/aws"
  version                      = "1.0.3"
  name                         = "mfa"
  environment                  = "test"
  inactive_days                = 1
  key_rotation_days            = 1
  mfa_enabled                  = true
  enable_key_rotation          = true
  enable_remove_inactive_users = true
}
```

## Example
For detailed examples on how to use this module, please refer to the [examples](https://github.com/cypik/terraform-aws-mfa/tree/master/example) directory within this repository.

## Author
Your Name Replace **MIT** and **Cypik** with the appropriate license and your information. Feel free to expand this README with additional details or usage instructions as needed for your specific use case.

## License
This project is licensed under the **MIT** License - see the [LICENSE](https://github.com/cypik/terraform-aws-mfa/blob/master/LICENSE) file for details.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.15.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.58.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | ~> 2.4.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.3.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.58.0 |
| <a name="provider_external"></a> [external](#provider\_external) | ~> 2.4.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_labels"></a> [labels](#module\_labels) | cypik/labels/aws | 1.0.4 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | resource |
| [aws_iam_group_membership.group_members](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_membership) | resource |
| [aws_iam_group_policy_attachment.assign_force_mfa_policy_to_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |
| [aws_iam_policy.enable_mfa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [null_resource.cleanup_status_files](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.detect_inactive_users](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.get_key_last_used](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.key_rotation](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.remove_inactive_users](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.remove_inactive_users_final](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.test_iam_access](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.time_check](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.track_removed_users](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_iam_access_keys.user_keys](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_access_keys) | data source |
| [aws_iam_policy_document.enable_mfa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_user.user_details](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_user) | data source |
| [aws_iam_users.all_users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_users) | data source |
| [external_external.password_last_used](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes (e.g. `1`). | `list(any)` | `[]` | no |
| <a name="input_enable_key_rotation"></a> [enable\_key\_rotation](#input\_enable\_key\_rotation) | Enable or disable key rotation logic | `bool` | `false` | no |
| <a name="input_enable_remove_inactive_users"></a> [enable\_remove\_inactive\_users](#input\_enable\_remove\_inactive\_users) | Enable or disable inactive user removal logic | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| <a name="input_groups"></a> [groups](#input\_groups) | enable MFA for the members in these groups | `list(string)` | <pre>[<br>  "mfa-required"<br>]</pre> | no |
| <a name="input_iam_users"></a> [iam\_users](#input\_iam\_users) | List of IAM users to manage | `list(string)` | `[]` | no |
| <a name="input_inactive_days"></a> [inactive\_days](#input\_inactive\_days) | Number of days after which inactive users are deleted | `number` | `90` | no |
| <a name="input_key_rotation_days"></a> [key\_rotation\_days](#input\_key\_rotation\_days) | Number of days after which access keys should be rotated | `number` | `90` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | Label order, e.g. `name`,`application`. | `list(any)` | <pre>[<br>  "name",<br>  "environment"<br>]</pre> | no |
| <a name="input_managedby"></a> [managedby](#input\_managedby) | ManagedBy, eg 'info@cypik.com'. | `string` | `"info@cypik.com"` | no |
| <a name="input_mfa_enabled"></a> [mfa\_enabled](#input\_mfa\_enabled) | Enable or disable MFA enforcement | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name  (e.g. `test` or `mfa`). | `string` | n/a | yes |
| <a name="input_path"></a> [path](#input\_path) | The path of the policy in MFA. | `string` | `"/"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `""` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Terraform current module repo | `string` | `"https://github.com/cypik/terraform-aws-mfa"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_active_users"></a> [active\_users](#output\_active\_users) | List of active IAM users |
| <a name="output_all_iam_users"></a> [all\_iam\_users](#output\_all\_iam\_users) | All IAM users in the account |
| <a name="output_current_timestamp"></a> [current\_timestamp](#output\_current\_timestamp) | Current timestamp for debugging |
| <a name="output_debug_key_dates"></a> [debug\_key\_dates](#output\_debug\_key\_dates) | Debug information for key dates |
| <a name="output_debug_user_attributes"></a> [debug\_user\_attributes](#output\_debug\_user\_attributes) | n/a |
| <a name="output_iam_arn"></a> [iam\_arn](#output\_iam\_arn) | The ARN assigned by AWS to this policy. |
| <a name="output_inactive_user_ages"></a> [inactive\_user\_ages](#output\_inactive\_user\_ages) | Age of inactive users in days |
| <a name="output_inactive_users_to_remove"></a> [inactive\_users\_to\_remove](#output\_inactive\_users\_to\_remove) | List of inactive users that will be removed |
| <a name="output_inactivity_threshold"></a> [inactivity\_threshold](#output\_inactivity\_threshold) | Current inactivity threshold in days |
| <a name="output_key_age_info"></a> [key\_age\_info](#output\_key\_age\_info) | Formatted key age information |
| <a name="output_key_ages"></a> [key\_ages](#output\_key\_ages) | Age information for all access keys |
| <a name="output_password_last_used_info"></a> [password\_last\_used\_info](#output\_password\_last\_used\_info) | n/a |
| <a name="output_removal_execution_plan"></a> [removal\_execution\_plan](#output\_removal\_execution\_plan) | Plan for user removal execution |
| <a name="output_removal_summary"></a> [removal\_summary](#output\_removal\_summary) | Summary of user removal activities |
| <a name="output_rotation_summary"></a> [rotation\_summary](#output\_rotation\_summary) | Summary of key rotation activities |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | Additional tags e.g. map(`BusinessUnit`,`XYZ`) |
| <a name="output_user_ages"></a> [user\_ages](#output\_user\_ages) | Age of each IAM user in days |
| <a name="output_user_inactivity_status"></a> [user\_inactivity\_status](#output\_user\_inactivity\_status) | n/a |
| <a name="output_user_last_access_dates"></a> [user\_last\_access\_dates](#output\_user\_last\_access\_dates) | Last access dates for all users |
| <a name="output_user_removal_status"></a> [user\_removal\_status](#output\_user\_removal\_status) | Status of user removal operations |
| <a name="output_users_needing_rotation"></a> [users\_needing\_rotation](#output\_users\_needing\_rotation) | Users who need access key rotation |
| <a name="output_users_with_keys"></a> [users\_with\_keys](#output\_users\_with\_keys) | List of users who have access keys |
<!-- END_TF_DOCS -->