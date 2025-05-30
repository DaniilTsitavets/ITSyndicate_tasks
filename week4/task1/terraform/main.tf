terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }

  backend "s3" {
    encrypt      = true
    bucket       = "backend-58490149"
    region       = "eu-north-1"
    key          = "terraform.tfstate"
    use_lockfile = true
  }
  required_version = "~> 1.10"
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    app_ids = aws_instance.django_app[*].id
    db_ids  = aws_instance.db[*].id
    region  = var.region
  })
  filename = "${path.module}/../ansible/hosts"
}

resource "local_file" "ansible_vars" {
  content = templatefile("${path.module}/vars.tpl", {
    vpc_cidr_block=aws_vpc.django_vpc.cidr_block
    db_host=aws_instance.db[0].private_ip
  })
  filename = "${path.module}/../ansible/group_vars/all"
}
