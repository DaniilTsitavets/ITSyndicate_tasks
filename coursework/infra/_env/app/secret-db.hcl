locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "tfr:///terraform-aws-modules/secrets-manager/aws?version=1.3.1"
}

inputs = {
  name_prefix             = "${local.env_vars.locals.environment}-"
  recovery_window_in_days = 30
  create_policy           = false
  block_public_policy     = true
  create_random_password  = true
  random_password_length  = 64
  random_password_override_special = "%^*()_"

  tags = {
    Environment = "${local.env_vars.locals.environment}"
  }
}
