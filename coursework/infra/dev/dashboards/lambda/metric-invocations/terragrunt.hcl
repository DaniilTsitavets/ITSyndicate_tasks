include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "tfr:///HENNGE/cloudwatch-dashboard/aws//modules/widget/metric/metric?version=1.0.2"
}

inputs = {
  namespace  = "AWS/Lambda"
  metricName = "Invocations"
  dimensions = {
    FunctionName = "${local.env_vars.locals.environment}-lambda"
  }
}