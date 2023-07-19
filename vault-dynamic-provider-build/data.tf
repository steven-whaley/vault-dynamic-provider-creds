data "aws_availability_zones" "available" {
  state = "available"
}

data "tfe_outputs" "vault_dpc_instruqt_init" {
  organization = "swhashi"
  workspace    = "vault-dpc-instruqt-init"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "vault_aws_secrets_user_policy" {
  statement {
    sid       = "VaultAWSSecretsUserPolicy"
    actions   = [        
        "iam:AttachUserPolicy",
        "iam:CreateAccessKey",
        "iam:CreateUser",
        "iam:DeleteAccessKey",
        "iam:DeleteUser",
        "iam:DeleteUserPolicy",
        "iam:DetachUserPolicy",
        "iam:GetUser",
        "iam:ListAccessKeys",
        "iam:ListAttachedUserPolicies",
        "iam:ListGroupsForUser",
        "iam:ListUserPolicies",
        "iam:PutUserPolicy",
        "iam:AddUserToGroup",
        "iam:RemoveUserFromGroup"
    ]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/vault-*"]
  }
}

data "aws_iam_policy_document" "vault_aws_plan_policy" {
  statement {
    sid       = "VaultAWSSecretsUserPolicy"
    actions   = [        
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteTags",
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeInstanceAttribute",
                "ec2:DescribeInstanceCreditSpecifications",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeInstances",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSecurityGroupRules",
                "ec2:DescribeTags",
                "ec2:DescribeVolumes",
                "ec2:ModifyInstanceAttribute",
                "ec2:MonitorInstances",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:RunInstances",
                "ec2:StartInstances",
                "ec2:StopInstances",
                "ec2:TerminateInstances",
                "ec2:UnmonitorInstances",
                "ec2:CreateKeyPair",
                "ec2:DeleteKeyPair",
                "ec2:DescribeKeyPairs",
                "ec2:ImportKeyPair",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "vault_aws_apply_policy" {
  statement {
    sid       = "VaultAWSSecretsUserPolicy"
    actions   = [        
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteTags",
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeInstanceAttribute",
                "ec2:DescribeInstanceCreditSpecifications",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeInstances",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSecurityGroupRules",
                "ec2:DescribeTags",
                "ec2:DescribeVolumes",
                "ec2:ModifyInstanceAttribute",
                "ec2:MonitorInstances",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:RunInstances",
                "ec2:StartInstances",
                "ec2:StopInstances",
                "ec2:TerminateInstances",
                "ec2:UnmonitorInstances",
                "ec2:CreateKeyPair",
                "ec2:DeleteKeyPair",
                "ec2:DescribeKeyPairs",
                "ec2:ImportKeyPair",
    ]
    resources = ["*"]
  }
}