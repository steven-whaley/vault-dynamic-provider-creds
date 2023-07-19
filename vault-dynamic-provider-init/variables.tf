variable "hvn_cidr" {
  type = string
  description = "CIDR block of the HVN to create for the Vault cluster"
}

variable "region" {
  type = string
  description = "The AWS region to deploy infrastructure into"
}