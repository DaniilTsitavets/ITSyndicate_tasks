resource "aws_db_instance" "db" {
  allocated_storage    = var.allocated_storage
  engine               = var.engine
  engine_version       = var.engine_version
  password             = data.aws_ssm_parameter.db_password.value
  username             = data.aws_ssm_parameter.db_username.value
  db_name              = data.aws_ssm_parameter.db_name.value
  instance_class       = var.instance_class
  db_subnet_group_name = aws_db_subnet_group.task1_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]


  publicly_accessible = false
  skip_final_snapshot = true
  storage_encrypted   = true
  apply_immediately   = true

  tags = {
    Name = "task1-rds-instance"
  }
}