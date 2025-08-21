include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "tfr:///HENNGE/cloudwatch-dashboard/aws//modules/widget/metric?version=1.0.2"
}

dependency "metric-db-connections" {
  config_path = find_in_parent_folders("metric-db-connections")
}

inputs = {
  title  = "Amount of db connections ${local.env_vars.locals.environment}-db"
  region = "eu-north-1"
  width  = 12
  period = 60
  metrics = [
    dependency.metric-db-connections.outputs.metric_array_object
  ]
}