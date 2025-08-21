locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  tags = local.env_vars.locals.tags
}

terraform {
  source = "tfr:///terraform-aws-modules/ecs/aws//modules/cluster?version=6.2.1"
}

inputs = {
  name = "${local.env_vars.locals.environment}-ecs-fargate-cluster"

  configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/${local.env_vars.locals.environment}"
      }
    }
  }

  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 50
      base   = 0
    }
    FARGATE_SPOT = {
      weight = 50
    }
  }

  tags = local.tags
}