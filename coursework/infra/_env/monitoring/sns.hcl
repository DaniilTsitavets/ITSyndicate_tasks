locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "tfr:///terraform-aws-modules/sns/aws?version=6.2.0"
}

dependency "lambda-email" {
  config_path = find_in_parent_folders("lambda-email")
}

inputs = {
  use_name_prefix = true
  name = "${local.env_vars.locals.environment}-alarms-to-mail"
  subscriptions = {
    lambda-email = {
      protocol = "lambda"
      endpoint = "${dependency.lambda-email.outputs.lambda_function_arn}"
    }
  }

  tags = {
    Environment = "${local.env_vars.locals.environment}"
    Terraform   = "true"
  }
}