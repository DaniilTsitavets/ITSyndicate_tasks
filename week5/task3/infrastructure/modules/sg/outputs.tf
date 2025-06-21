output "alb_sg_id" {
  value = aws_security_group.task3_alb_sg.id
}

output "ec2_sg_id" {
  value = aws_security_group.task3_ec2_sg.id
}

output "rds_sg_id" {
  value = aws_security_group.task3_rds_sg.id
}