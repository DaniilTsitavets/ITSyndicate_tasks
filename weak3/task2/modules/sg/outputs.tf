output "ec2_sg" {
  value = aws_security_group.demo_ec2_sg.id
}

output "alb_sg" {
  value = aws_security_group.demo_alb_sg.id
}