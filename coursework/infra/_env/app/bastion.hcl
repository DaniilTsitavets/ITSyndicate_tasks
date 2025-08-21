locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "tfr:///terraform-aws-modules/ec2-instance/aws?version=6.0.2"
}

dependency "vpc" {
  config_path = find_in_parent_folders("vpc")
}

dependency "bastion-sg" {
  config_path = find_in_parent_folders("bastion-sg")
}

inputs = {
  name                        = "${local.env_vars.locals.environment}-bastion"
  instance_type               = "t3.micro"
  ami                         = "ami-042b4708b1d05f512"
  key_name                    = "${local.env_vars.locals.environment}-pk"
  monitoring                  = true
  subnet_id                   = dependency.vpc.outputs.public_subnets[0]
  associate_public_ip_address = true
  create_security_group       = false

  vpc_security_group_ids = [dependency.bastion-sg.outputs.security_group_id]

  tags = local.env_vars.locals.tags
}

