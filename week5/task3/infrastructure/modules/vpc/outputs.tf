output "vpc_id" {
  value = aws_vpc.task3_vpc.id
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private : subnet.id]
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public : subnet.id]
}

output "isolated_subnet_ids" {
  value = [for subnet in aws_subnet.isolated : subnet.id]
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.db_subnet_group.name
}