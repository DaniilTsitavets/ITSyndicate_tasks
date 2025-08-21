include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  is_valid_env = contains(["staging", "prod"], local.env_vars.locals.environment) ? true : false
  subdomain    = contains(["staging", "prod"], local.env_vars.locals.environment) ? "" : "${local.env_vars.locals.environment}."
}

terraform {
  source = "tfr:///terraform-aws-modules/cloudfront/aws?version=5.0.0"
  after_hook "add-s3-policy" {
    commands = ["apply"]
    execute = ["./add-s3-policy.sh"]
    run_on_error = false
  }
}

dependency "s3-bucket" {
  config_path = find_in_parent_folders("s3-bucket")
}

dependency "api-gateway" {
  config_path = find_in_parent_folders("api-gateway")
}

dependency "acm" {
  config_path = find_in_parent_folders("acm")
}

inputs = {
  aliases = ["${local.subdomain}${local.env_vars.locals.route53.domain}"]
  enabled             = true
  is_ipv6_enabled     = false
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_identity = false
  create_origin_access_control  = true
  origin_access_control = {
    s3_oac = {
      description      = "CloudFront access to S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  origin = {
    api_gateway = {
      domain_name = dependency.api-gateway.outputs.stage_domain_name
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols = ["TLSv1.2"]
      }
    }

    s3_oac = {
      domain_name           = dependency.s3-bucket.outputs.s3_bucket_bucket_regional_domain_name
      origin_access_control = "s3_oac"
    }
  }

  default_cache_behavior = {
    target_origin_id       = "api_gateway"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods = ["GET", "HEAD"]

    use_forwarded_values = false

    cache_policy_name            = "Managed-CachingDisabled"
    origin_request_policy_name   = "Managed-AllViewerExceptHostHeader"
    response_headers_policy_name = "Managed-SimpleCORS"

    compress               = true
    query_string           = true
  }

  ordered_cache_behavior = [
    {
      path_pattern           = "/static/*"
      target_origin_id       = "s3_oac"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name            = "Managed-CachingOptimized"
      origin_request_policy_name   = "Managed-UserAgentRefererHeaders"
      response_headers_policy_name = "Managed-SimpleCORS"
      compress               = true
      query_string           = false
    }
  ]

  viewer_certificate = {
    acm_certificate_arn      = dependency.acm.outputs.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}