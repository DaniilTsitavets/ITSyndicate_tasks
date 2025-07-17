output "private_ips" {
  value = [aws_instance.k8s-hard-way-ec2-instance[*].private_ip]
}

output "bastion_connect" {
  value = "ssh -i ./Downloads/pem/coursework-bastion-kp.pem ubuntu@${aws_instance.bastion[0].public_ip}"
}