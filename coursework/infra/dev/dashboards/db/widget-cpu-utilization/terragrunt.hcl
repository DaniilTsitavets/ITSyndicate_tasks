include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "tfr:///HENNGE/cloudwatch-dashboard/aws//modules/widget/metric?version=1.0.2"
}

dependency "metric-cpu-utilization" {
  config_path = find_in_parent_folders("metric-cpu-utilization")
}

inputs = {
  title  = "CPU utilization of ${local.env_vars.locals.environment}-db"
  region = "eu-north-1"
  width = 12
  period = 60
  metrics = [
    dependency.metric-cpu-utilization.outputs.metric_array_object
  ]
}