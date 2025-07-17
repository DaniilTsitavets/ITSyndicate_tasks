resource "aws_instance" "bastion" {
  ami           = var.ami
  instance_type = var.bastion_instance_type
  subnet_id     = aws_subnet.k8s_hard_way_public_subnet[0].id
  count         = 1
  security_groups = [aws_security_group.bastion_sg.id]
  key_name      = "coursework-bastion-kp"
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install -y software-properties-common
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    sudo apt install -y ansible
    sudo ansible-galaxy collection install community.kubernetes
  EOF

  tags = {
    Name = "bastion"
  }
}

resource "aws_instance" "k8s-hard-way-ec2-instance" {
  ami                         = var.ami
  instance_type               = var.other_nodes_instance_type
  subnet_id                   = aws_subnet.k8s_hard_way_public_subnet[0].id
  count                       = 3
  security_groups = [aws_security_group.other_nodes_sg.id]
  associate_public_ip_address = true
  key_name                    = "coursework-bastion-kp"

  tags = {
    Name = "k8s-hard-way-ec2-instance-${count.index}"
  }
}