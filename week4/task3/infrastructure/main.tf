terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }

  backend "s3" {
    encrypt      = true
    bucket       = "backend-58490149"
    region       = "eu-north-1"
    key          = "terraform.tfstate"
    use_lockfile = true
  }
  required_version = ">= 1.10"
}

module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "2.0.2"

  key_name   = "ansible-key-pair"
  public_key = tls_private_key.example.public_key_openssh
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.example.private_key_pem
  filename = "${path.module}/ansible-key.pem"
  file_permission = "0400"
}

resource "local_file" "inventory" {
  content = templatefile("${path.module}/inventory.ini.tpl", {
    web = module.web.private_ip
    db  = module.db.private_ip
  })
  filename = "../ansible/inventory.ini"
}