output "eks_cluster_name" {
  value = aws_eks_cluster.task1_eks_cluster.name
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --region eu-north-1 --name ${aws_eks_cluster.task1_eks_cluster.name}"
}

output "rds_endpoint" {
  value = aws_db_instance.db.endpoint
}

output "ecr_repo_url" {
  value = aws_ecr_repository.task1_ecr.repository_url
}