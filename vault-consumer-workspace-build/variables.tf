variable "aws_region" {
    type = string
    description = "AWS Region"
    default = "us-west-2"
}

variable "aws_key_name" {
    type = string
    description = "EC2 instance public key to add for SSH access"
    default = "sw-ec2key"
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