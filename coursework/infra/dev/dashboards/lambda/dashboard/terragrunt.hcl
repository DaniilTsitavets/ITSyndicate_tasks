include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "tfr:///HENNGE/cloudwatch-dashboard/aws?version=1.0.2"
}

dependency "widget-invocations" {
  config_path = find_in_parent_folders("widget-invocations")
}

dependency "widget-duration" {
  config_path = find_in_parent_folders("widget-duration")
}

dependency "widget-errors" {
  config_path = find_in_parent_folders("widget-errors")
}

dependency "widget-throttles" {
  config_path = find_in_parent_folders("widget-throttles")
}

inputs = {
  name = "${local.env_vars.locals.environment}-lambda-dashboard"

  widgets = [
    dependency.widget-invocations.outputs.widget_object,
    dependency.widget-duration.outputs.widget_object,
    dependency.widget-errors.outputs.widget_object,
    dependency.widget-throttles.outputs.widget_object
  ]
}