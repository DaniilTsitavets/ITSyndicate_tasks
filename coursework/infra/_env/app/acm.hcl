locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "tfr:///terraform-aws-modules/acm/aws?version=6.1.0"
}

inputs = {
  domain_name = local.env_vars.locals.route53.domain
  zone_id     = local.env_vars.locals.route53.hosted_zone_id

  validation_method = "DNS"

  subject_alternative_names = [
    "*.${local.env_vars.locals.route53.domain}"
  ]

  region = "us-east-1"
  wait_for_validation = true

  tags = {
    Name = "${local.env_vars.locals.route53.domain}"
  }
}