locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  tags = local.env_vars.locals.tags
}

terraform {
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-role?version=6.0.0"
}

dependency "collectstatic-task-policy" {
  config_path = find_in_parent_folders("collectstatic-task-policy")
}

inputs = {
  name = "${local.env_vars.locals.environment}-collectstatic-task-role"

  trust_policy_permissions = {
    AllowECS = {
      actions = ["sts:AssumeRole"]
      principals = [
        {
          type = "Service"
          identifiers = ["ecs-tasks.amazonaws.com"]
        }
      ]
    }
  }

  policies = {
    collectstatic = dependency.collectstatic-task-policy.outputs.arn
  }

  tags = local.tags
}