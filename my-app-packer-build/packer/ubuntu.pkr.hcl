packer {
  required_version = ">= 1.7.0"
  required_plugins {
    amazon = {
      version = ">= 1.0.3"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

data "hcp-packer-iteration" "base-ubuntu" {
  bucket_name = "hcp-ubuntu-base"
  channel     = "latest"
}

data "hcp-packer-image" "aws" {
  bucket_name    = data.hcp-packer-iteration.base-ubuntu.bucket_name
  iteration_id   = data.hcp-packer-iteration.base-ubuntu.id
  cloud_provider = "aws"
  region         = "us-west-2"
}

source "amazon-ebs" "myapp" {
  region         = "us-west-2"
  source_ami     = data.hcp-packer-image.aws.id
  instance_type  = "t2.nano"
  ssh_username   = "ubuntu"
  ssh_agent_auth = false
  ami_name       = "${var.image_name}_{{timestamp}}"
  tags = merge(var.default_base_tags, {
    SourceAMIName        = "{{ .SourceAMIName }}"
    builddate            = formatdate("MMM DD, YYYY", timestamp())
    buildtime            = formatdate("HH:mmaa", timestamp())
    SourceImageChannel   = data.hcp-packer-iteration.base-ubuntu.channel_id
    SourceImageIteration = data.hcp-packer-iteration.base-ubuntu.id
  })
}

build {
  hcp_packer_registry {
    bucket_name = var.image_name
    description = "Simple static website"

    bucket_labels = var.default_base_tags

    build_labels = {
      "builddate"                = formatdate("MMM DD, YYYY", timestamp())
      "buildtime"                = formatdate("HH:mmaa", timestamp())
      "operating-system"         = "Ubuntu"
      "operating-system-release" = "22.04"
    }
  }

  sources = ["source.amazon-ebs.myapp"]

  // Copy binary to tmp
  provisioner "file" {
    source      = "../bin/server"
    destination = "/tmp/"
  }

  provisioner "file" {
    source      = "./scripts/myapp.service"
    destination = "/tmp/"
  }

  provisioner "shell" {
    script = "./scripts/setup.sh"
  }

  post-processor "manifest" {
    output     = "packer_manifest.json"
    strip_path = true
    custom_data = {
      iteration_id = packer.iterationID
    }
  }
}
