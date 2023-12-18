module "labels" {
  source      = "git::https://github.com/cypik/terraform-aws-labels.git?ref=v1.0.0"
  name        = var.name
  environment = var.environment
  attributes  = var.attributes
  repository  = var.repository
  managedby   = var.managedby
  label_order = var.label_order
}

resource "aws_iam_policy" "enable_mfa" {
  name        = var.name
  path        = var.path
  description = "Policy to enable MFA "
  policy      = data.aws_iam_policy_document.enable_mfa.json
  tags = merge(
    module.labels.tags,
    {
      "Name" = module.labels.id
    }
  )
}
#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "enable_mfa" {

  statement {
    sid    = "VisualEditor0"
    effect = "Allow"
    actions = [
      "iam:GetPolicyVersion",
      "iam:GetAccountPasswordPolicy",
      "iam:ListRoleTags",
      "iam:ListServerCertificates",
      "iam:GenerateServiceLastAccessedDetails",
      "iam:ListServiceSpecificCredentials",
      "iam:ListSigningCertificates",
      "iam:ListVirtualMFADevices",
      "iam:ListSSHPublicKeys",
      "iam:SimulateCustomPolicy",
      "iam:SimulatePrincipalPolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListOpenIDConnectProviderTags",
      "iam:ListSAMLProviderTags",
      "iam:ListRolePolicies",
      "iam:GetAccountAuthorizationDetails",
      "iam:GetCredentialReport",
      "iam:ListPolicies",
      "iam:GetServerCertificate",
      "iam:GetRole",
      "iam:ListSAMLProviders",
      "iam:GetPolicy",
      "iam:GetAccessKeyLastUsed",
      "iam:ListEntitiesForPolicy",
      "iam:GetUserPolicy",
      "iam:ListGroupsForUser",
      "iam:GetGroupPolicy",
      "iam:GetOpenIDConnectProvider",
      "iam:GetRolePolicy",
      "iam:GetAccountSummary",
      "iam:GenerateCredentialReport",
      "iam:GetServiceLastAccessedDetailsWithEntities",
      "iam:ListPoliciesGrantingServiceAccess",
      "iam:ListInstanceProfileTags",
      "iam:ListMFADevices",
      "iam:GetServiceLastAccessedDetails",
      "iam:GetGroup",
      "iam:GetContextKeysForPrincipalPolicy",
      "iam:GetOrganizationsAccessReport",
      "iam:GetServiceLinkedRoleDeletionStatus",
      "iam:ListInstanceProfilesForRole",
      "iam:GenerateOrganizationsAccessReport",
      "iam:EnableMFADevice",
      "iam:ListAttachedUserPolicies",
      "iam:ListAttachedGroupPolicies",
      "iam:ListPolicyTags",
      "iam:GetSAMLProvider",
      "iam:ListAccessKeys",
      "iam:GetInstanceProfile",
      "iam:ListGroupPolicies",
      "iam:GetSSHPublicKey",
      "iam:ListRoles",
      "iam:ListUserPolicies",
      "iam:ListInstanceProfiles",
      "iam:GetContextKeysForCustomPolicy",
      "iam:ListPolicyVersions",
      "iam:ListOpenIDConnectProviders",
      "iam:ListServerCertificateTags",
      "iam:ListAccountAliases",
      "iam:ListUsers",
      "iam:GetUser",
      "iam:ListGroups",
      "iam:ListMFADeviceTags",
      "iam:GetLoginProfile",
      "iam:ListUserTags"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_group_policy_attachment" "assign_force_mfa_policy_to_groups" {
  count      = length(var.groups)
  group      = element(var.groups, count.index)
  policy_arn = aws_iam_policy.enable_mfa.arn
}

resource "aws_iam_user_policy_attachment" "assign_force_mfa_policy_to_users" {
  count      = length(var.users)
  user       = element(var.users, count.index)
  policy_arn = aws_iam_policy.enable_mfa.arn
}
