include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "tfr:///HENNGE/cloudwatch-dashboard/aws//modules/widget/metric?version=1.0.2"
}

dependency "metric-freeable-memory" {
  config_path = find_in_parent_folders("metric-freeable-memory")
}

inputs = {
  title  = "Free able memory of ${local.env_vars.locals.environment}-db"
  region = "eu-north-1"
  width = 12
  period = 3000
  metrics = [
    dependency.metric-freeable-memory.outputs.metric_array_object
  ]
}