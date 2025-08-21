include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  is_valid_env = contains(["staging", "prod"], local.env_vars.locals.environment) ? true : false
  username = local.env_vars.locals.username
  db_name  = local.env_vars.locals.db_name
}

terraform {
  source = "tfr:///terraform-aws-modules/rds/aws?version=6.12.0"
}

dependency "vpc" {
  config_path = find_in_parent_folders("vpc")
}

dependency "rds-sg" {
  config_path = find_in_parent_folders("rds-sg")
}

dependency "secret-db" {
  config_path = find_in_parent_folders("secret-db")
}

inputs = {
  identifier                 = "${local.env_vars.locals.environment}-db"
  engine                     = "postgres"
  major_engine_version       = "17"
  auto_minor_version_upgrade = true
  instance_class             = "db.t3.micro"
  allocated_storage          = 5
  family                     = "postgres17"
  port                       = "5432"

  manage_master_user_password = false
  password                    = dependency.secret-db.outputs.secret_string
  username                    = local.username
  db_name                     = local.db_name

  create_cloudwatch_log_group = true
  cloudwatch_log_group_class  = "STANDARD"
  enabled_cloudwatch_logs_exports = ["postgresql"]
  create_monitoring_role      = true

  create_db_subnet_group = true
  subnet_ids             = dependency.vpc.outputs.private_subnets
  vpc_security_group_ids = [dependency.rds-sg.outputs.security_group_id]
  deletion_protection    = local.is_valid_env
}