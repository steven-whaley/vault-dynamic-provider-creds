
variable "image_name" {
  type    = string
  default = "hcp-packer-myapp"
}

variable "default_base_tags" {
  description = "Required tags for the environment"
  type        = map(string)
  default = {
    owner   = "App Team"
    contact = "myapp@swcloudlab.net"
  }
}