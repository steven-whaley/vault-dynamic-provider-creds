data "aws_availability_zones" "available" {
  state = "available"
}

data "tfe_outputs" "vault_dynamic_provider_init" {
  organization = "swhashi"
  workspace    = "vault-dynamic-provider-init"
}

data "aws_arn" "peer_vpc" {
  arn = module.vault-dynamic-provider-vpc.vpc_arn
}

locals {
  my_email = split("/", data.aws_caller_identity.current.arn)[2]
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Vault Mount AWS Config Setup

data "aws_iam_policy" "demo_user_permissions_boundary" {
  name = "DemoUser"
}

data "aws_iam_policy_document" "vault_dynamic_iam_user_policy" {
  statement {
    sid       = "VaultDemoUserDescribeEC2Regions"
    actions   = ["ec2:*"]
    resources = ["*"]
  }
}