terraform {
  required_providers {
    aws = {
      version = "5.4.0"
      source  = "hashicorp/aws"
    }
    tfe = {
      version = "0.45.0"
    }
    vault = {
      version = "3.16.0"
    }
  }
  cloud {
    organization = "swhashi"
    workspaces {
      name = "vault-consumer-workspace-build"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "tfe" {}

provider "vault" {
  address   = data.tfe_outputs.vault_dynamic_provider_init.values.vault_pub_url
  token     = data.tfe_outputs.vault_dynamic_provider_init.values.vault_token
  namespace = "admin"
}