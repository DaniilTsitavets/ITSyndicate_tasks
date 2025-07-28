output "eks_cluster_name" {
  value = aws_eks_cluster.task1_eks_cluster.name
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --region eu-north-1 --name ${aws_eks_cluster.task1_eks_cluster.name}"
}
