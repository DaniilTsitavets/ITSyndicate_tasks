output "app_ids" {
  value = [aws_instance.django_app[*].id]
}

output "db_ids" {
  value = [aws_instance.db[*].id]
}

output "db_host" {
  value = [aws_instance.db[*].private_ip]
}

output "vpc_cidr_block" {
  value = aws_vpc.django_vpc.cidr_block
}
