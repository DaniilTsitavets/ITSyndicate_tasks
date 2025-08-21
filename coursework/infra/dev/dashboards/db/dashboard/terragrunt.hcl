include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "tfr:///HENNGE/cloudwatch-dashboard/aws?version=1.0.2"
}

dependency "widget-cpu-utilization" {
  config_path = find_in_parent_folders("widget-cpu-utilization")
}

dependency "widget-db-connections" {
  config_path = find_in_parent_folders("widget-db-connections")
}

dependency "widget-free-storage-space" {
  config_path = find_in_parent_folders("widget-free-storage-space")
}

dependency "widget-freeable-memory" {
  config_path = find_in_parent_folders("widget-freeable-memory")
}

inputs = {
  name = "${local.env_vars.locals.environment}-db-dashboard"

  widgets = [
    dependency.widget-db-connections.outputs.widget_object,
    dependency.widget-cpu-utilization.outputs.widget_object,
    dependency.widget-free-storage-space.outputs.widget_object,
    dependency.widget-freeable-memory.outputs.widget_object
  ]
}