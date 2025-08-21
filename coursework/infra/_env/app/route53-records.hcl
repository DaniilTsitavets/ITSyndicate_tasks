locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  subdomain = contains(["staging", "prod"], local.env_vars.locals.environment) ? "" : local.env_vars.locals.environment
}

terraform {
  source = "tfr:///terraform-aws-modules/route53/aws//modules/records?version=5.0.0"
}

dependency "cdn" {
  config_path = find_in_parent_folders("cdn")
}

inputs = {
  zone_name = local.env_vars.locals.route53.hosted_zone_name

  records = [
    {
      name = local.subdomain
      type = "A"
      alias = {
        name    = dependency.cdn.outputs.cloudfront_distribution_domain_name
        zone_id = "Z2FDTNDATAQYW2"
      }
    }
  ]
}