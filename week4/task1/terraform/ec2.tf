resource "aws_instance" "django_app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  count                = 2
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
  subnet_id = aws_subnet.django_private_subnet[0].id
  security_groups = [aws_security_group.ec2_django_app_sg.id]

  tags = {
    Name = "django-app"
    Role = "app"
  }
}


resource "aws_instance" "db" {
  ami           = var.ami_id
  instance_type = var.instance_type
  count                = 1
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
  subnet_id = aws_subnet.django_private_subnet[0].id
  security_groups = [aws_security_group.ec2_db_sg.id]

  tags = {
    Name = "db"
    Role = "db"
  }
}
