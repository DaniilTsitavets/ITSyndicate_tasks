terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    control_plane = {
      private_ip = aws_instance.k8s-hard-way-ec2-instance[0].private_ip
    },
    workers = [
      {
        name       = "node-0"
        private_ip = aws_instance.k8s-hard-way-ec2-instance[1].private_ip
      },
      {
        name       = "node-1"
        private_ip = aws_instance.k8s-hard-way-ec2-instance[2].private_ip
      }
    ]
  })

  filename = "${path.module}/../ansible/inventory.ini"
}