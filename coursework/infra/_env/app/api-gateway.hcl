locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  subdomain = contains(["staging", "prod"], local.env_vars.locals.environment) ? "" : "${local.env_vars.locals.environment}."
}

terraform {
  source = "tfr:///terraform-aws-modules/apigateway-v2/aws?version=5.3.0"
  after_hook "add-lambda-perms" {
    commands = ["apply"]
    execute = ["./add-lambda-perms.sh"]
    run_on_error = true
  }
}

dependency "lambda" {
  config_path = find_in_parent_folders("lambda")
}

inputs = {
  name          = "${local.env_vars.locals.environment}-http"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_origins = ["https://${local.subdomain}${local.env_vars.locals.route53.domain}"]
  }
  create_domain_name    = false
  create_domain_records = false

  stage_access_log_settings = {
    create_log_group            = true
    log_group_retention_in_days = 7
    format = jsonencode({
      context = {
        integrationErrorMessage = "$context.integrationErrorMessage"
        protocol                = "$context.protocol"
        requestId               = "$context.requestId"
        requestTime             = "$context.requestTime"
        responseLength          = "$context.responseLength"
        routeKey                = "$context.routeKey"
        stage                   = "$context.stage"
        status                  = "$context.status"
        error = {
          message      = "$context.error.message"
          responseType = "$context.error.responseType"
        }
        identity = {
          sourceIP = "$context.identity.sourceIp"
        }
        integration = {
          error             = "$context.integration.error"
          integrationStatus = "$context.integration.integrationStatus"
        }
      }
    })
  }

  routes = {
    "ANY /" = {
      integration = {
        uri                    = dependency.lambda.outputs.lambda_function_arn
        payload_format_version = "2.0"
        timeout_milliseconds   = 30000
      }
    }
  }

  tags = {
    Environment = "${local.env_vars.locals.environment}"
    Terraform   = "true"
  }
}