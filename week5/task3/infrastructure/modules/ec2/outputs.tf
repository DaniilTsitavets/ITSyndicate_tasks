output "ec2_instance_ids" {
  value = [for instance in aws_instance.task3_ec2 : instance.id]
}