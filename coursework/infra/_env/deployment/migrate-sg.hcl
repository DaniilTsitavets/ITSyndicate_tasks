locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  tags = local.env_vars.locals.tags
}

terraform {
  source = "tfr:///terraform-aws-modules/security-group/aws?version=5.3.0"
}

dependency "vpc" {
  config_path = find_in_parent_folders("vpc")
}

inputs = {
  name        = "${local.env_vars.locals.environment}-migrate-task-definition-sg"
  description = "Security group for migration task definition"
  vpc_id      = dependency.vpc.outputs.vpc_id

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}