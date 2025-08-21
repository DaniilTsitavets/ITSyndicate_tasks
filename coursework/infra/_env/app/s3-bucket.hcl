locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  is_valid_env = contains(["staging", "prod"], local.env_vars.locals.environment) ? true : false
  subdomain = contains(["staging", "prod"], local.env_vars.locals.environment) ? "" : "${local.env_vars.locals.environment}."
}

terraform {
  source = "tfr:///terraform-aws-modules/s3-bucket/aws?version=5.3.1"
}

inputs = {
  region                   = "eu-north-1"
  bucket_prefix            = "${local.env_vars.locals.environment}-s3-bucket"
  acl                      = "private"
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  cors_rule = [
    {
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["https://${local.subdomain}${local.env_vars.locals.route53.domain}"]
      allowed_headers = ["*"]
      max_age_seconds = 3000
    }
  ]

  lifecycle_rule = [
    {
      id      = "expire-noncurrent-versions"
      enabled = true
      noncurrent_version_expiration = {
        days = 30
      }
    }
  ]
  force_destroy = local.is_valid_env

  versioning = {
    enabled = local.is_valid_env
  }
}