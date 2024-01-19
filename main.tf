module "labels" {
  source      = "cypik/labels/aws"
  version     = "1.0.1"
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
    sid    = "AllowViewAccountInfo"
    effect = "Allow"
    actions = [
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary",
      "iam:ListVirtualMFADevices",
      "iam:ListMFADevices"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowManageOwnPasswords"
    effect = "Allow"
    actions = [
      "iam:ChangePassword",
      "iam:GetUser",
      "iam:CreateLoginProfile",
      "iam:DeleteLoginProfile",
      "iam:GetLoginProfile",
      "iam:UpdateLoginProfile"
    ]
    resources = [
      "arn:aws:iam::*:user/&{aws:username}",
    ]
  }

  statement {
    sid    = "AllowManageOwnAccessKeys"
    effect = "Allow"
    actions = [
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey"

    ]
    resources = [
      "arn:aws:iam::*:user/&{aws:username}",
    ]

  }

  statement {
    sid    = "AllowManageOwnSigningCertificates"
    effect = "Allow"
    actions = [
      "iam:DeleteSigningCertificate",
      "iam:ListSigningCertificates",
      "iam:UpdateSigningCertificate",
      "iam:UploadSigningCertificate",
    ]
    resources = [
      "arn:aws:iam::*:user/&{aws:username}",
    ]
  }

  statement {
    sid    = "AllowManageOwnSSHPublicKeys"
    effect = "Allow"
    actions = [
      "iam:DeleteSSHPublicKey",
      "iam:GetSSHPublicKey",
      "iam:ListSSHPublicKeys",
      "iam:UpdateSSHPublicKey",
      "iam:UploadSSHPublicKey"

    ]
    resources = [
      "arn:aws:iam::*:user/&{aws:username}",
    ]
  }

  statement {
    sid    = "AllowManageOwnGitCredentials"
    effect = "Allow"
    actions = [
      "iam:CreateServiceSpecificCredential",
      "iam:DeleteServiceSpecificCredential",
      "iam:ListServiceSpecificCredentials",
      "iam:ResetServiceSpecificCredential",
      "iam:UpdateServiceSpecificCredential"
    ]
    resources = [
      "arn:aws:iam::*:user/&{aws:username}",
    ]
  }

  statement {
    sid    = "AllowManageOwnVirtualMFADevice"
    effect = "Allow"
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice"

    ]
    resources = [
      "arn:aws:iam::*:user/&{aws:username}",
    ]

  }

  statement {
    sid    = "AllowManageOwnUserMFA"
    effect = "Allow"
    actions = [
      "iam:DeactivateMFADevice",
      "iam:EnableMFADevice",
      "iam:ListMFADevices",
      "iam:ResyncMFADevice"

    ]
    resources = [
      "arn:aws:iam::*:user/&{aws:username}",
    ]
  }

  statement {
    sid    = "DenyAllExceptListedIfNoMFA"
    effect = "Deny"
    not_actions = [
      "iam:CreateVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:GetUser",
      "iam:ListUsers",
      "iam:GetMFADevice",
      "iam:ListMFADevices",
      "iam:ListVirtualMFADevices",
      "iam:ResyncMFADevice",
      "sts:GetSessionToken"
    ]

    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["false"]
    }
    condition {
      test     = "Bool"
      variable = "aws:ViaAWSService"
      values   = ["false"]
    }
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
