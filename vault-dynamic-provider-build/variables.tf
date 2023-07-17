variable "region" {
  type        = string
  description = "The region to create instrastructure in"
  default     = "us-west-2"
}

variable "aws_key_name" {
  type        = string
  description = "The name of the key pair in your AWS account that you would like to add to the EC2 instances that are created"
}

variable "tfc_hostname" {
  type        = string
  default     = "app.terraform.io"
  description = "The hostname of the TFC or TFE instance you'd like to use with Vault"
}

variable "db_admin_name" {
  type = string
  default = "postgres"
  description = "The name for the admin user to create in the RDS database"
}