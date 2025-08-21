locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "tfr:///terraform-aws-modules/security-group/aws?version=5.3.0"
}

dependency "vpc" {
  config_path = find_in_parent_folders("vpc")
}

dependency "bastion-sg" {
  config_path = find_in_parent_folders("bastion-sg")
}

dependency "lambda-sg" {
  config_path = find_in_parent_folders("lambda-sg")
}

dependency "migrate-sg" {
  config_path = find_in_parent_folders("migrate-sg")
}

inputs = {
  name        = "${local.env_vars.locals.environment}-rds-sg"
  description = "Security group for RDS database which allows"
  vpc_id      = dependency.vpc.outputs.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      source_security_group_id = dependency.bastion-sg.outputs.security_group_id
    },
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      source_security_group_id = dependency.migrate-sg.outputs.security_group_id
    },
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      source_security_group_id = dependency.lambda-sg.outputs.security_group_id
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