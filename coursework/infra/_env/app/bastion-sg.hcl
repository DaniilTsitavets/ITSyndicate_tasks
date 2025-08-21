locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "tfr:///terraform-aws-modules/security-group/aws?version=5.3.0"
}

dependency "vpc" {
  config_path = find_in_parent_folders("vpc")
}

inputs = {
  name        = "${local.env_vars.locals.environment}-bastion-sg"
  description = "Security group for RDS database which allows traffic from lambda and bastion"
  vpc_id      = dependency.vpc.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}