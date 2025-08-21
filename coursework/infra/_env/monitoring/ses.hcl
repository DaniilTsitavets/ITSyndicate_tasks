locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "tfr:///cloudposse/ses/aws?version=0.25.1"
}

inputs = {
  domain        = local.env_vars.locals.route53.domain
  zone_id       = local.env_vars.locals.route53.hosted_zone_id
  verify_dkim   = true
  verify_domain = true
  environment   = local.env_vars.locals.environment
}