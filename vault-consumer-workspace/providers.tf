terraform {
  required_providers {
    aws = {
      version = "5.4.0"
      source  = "hashicorp/aws"
    }
    vault = {
      version = "3.16.0"
    }
    hcp = {
      version = "0.63.0"
    }
  }
  cloud {
    organization = "swhashi"
    workspaces {
      name = "vault-consumer-workspace"
    }
  }
}

provider "aws" {
  region     = var.region
}


provider "vault" {
}

provider "hcp" {}