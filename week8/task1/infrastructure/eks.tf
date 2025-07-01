resource "aws_eks_cluster" "task1_eks_cluster" {
  name     = "task1-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = concat(
      aws_subnet.private[*].id,
      aws_subnet.public[*].id
    )
  }
}

resource "aws_eks_node_group" "task1_node_group" {
  cluster_name    = aws_eks_cluster.task1_eks_cluster.name
  node_group_name = "task1-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.private[*].id

  scaling_config {
    desired_size = 4
    max_size     = 5
    min_size     = 1
  }

  instance_types = ["t3.micro"]
  ami_type       = "AL2023_x86_64_STANDARD"
  disk_size      = 20
}

data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.task1_eks_cluster.name

  depends_on = [aws_eks_node_group.task1_node_group]
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.task1_eks_cluster.name

  depends_on = [aws_eks_node_group.task1_node_group]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "eks_aws_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.0"

  manage_aws_auth_configmap = true

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::913524929706:user/Daniil"
      username = "Daniil"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_roles = [
    {
      rolearn  = aws_iam_role.eks_node_role.arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
    {
      rolearn  = aws_iam_role.eks_cluster_role.arn
      username = "eks-cluster-role"
      groups   = ["system:masters"]
    }
  ]

  depends_on = [aws_eks_node_group.task1_node_group]
}
