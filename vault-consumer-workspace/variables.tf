variable "region" {
  type        = string
  description = "The region to create instrastructure in"
  default     = "us-west-2"
}

variable "public_key" {
  type        = string
  description = "The public key to use to to create a key pair for connecting to the EC2 instances"
}