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
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.63.0"
    }
  }
  cloud {
    organization = "swhashi"
    workspaces {
      name = "vault-dpc-instruqt-build"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "tfe" {}

provider "vault" {
  address   = data.tfe_outputs.vault_dpc_instruqt_init.values.vault_pub_url
  token     = data.tfe_outputs.vault_dpc_instruqt_init.values.vault_token
  namespace = "admin"
}

provider "hcp" {}