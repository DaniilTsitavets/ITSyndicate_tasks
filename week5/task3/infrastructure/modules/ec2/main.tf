resource "aws_instance" "task3_ec2" {
  ami                  = var.ami
  iam_instance_profile = var.iam_instance_profile_name
  instance_type        = var.instance_type
  subnet_id            = var.private_subnet_id
  count                = 1
  security_groups = [var.ec2_sg]

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    rds_host = var.rds_host
  })

  tags = {
    Name = "task3-ec2-instance"
  }
}