terraform {
  required_version = ">= 1.0"
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.63.0"
    }
  }
  cloud {
    organization = "swhashi"
    workspaces {
      name = "vault-dpc-instruqt-init"
    }
  }
}

provider "hcp" {}