variable "region" {
    type = string
    description = "AWS Region"
    default = "us-west-2"
}

variable "public_key" {
    type = string
    description = "Public key to use to connect to AWS instance"
}

variable "tfc_organization_name" {
    type = string
    description = "The organization name in which to create the consumer workspaces"
}

variable "tfc_hostname" {
    type = string
    description = "The URL of the TFC or TFE server to use for OIDC Authentication"
    default = "https://app.terraform.io"
}