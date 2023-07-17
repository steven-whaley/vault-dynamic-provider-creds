variable "region" {
  type        = string
  description = "The region to create instrastructure in"
  default     = "us-west-2"
}

variable "aws_key_name" {
  type        = string
  description = "The name of the key pair in your AWS account that you would like to add to the EC2 instances that are created"
  default     = "sw-ec2key"
}