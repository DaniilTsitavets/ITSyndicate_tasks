locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "tfr:///terraform-aws-modules/lambda/aws?version=8.0.1"

  extra_arguments "lambda_source" {
    commands = ["apply", "plan", "destroy"]
    arguments = [
      "-var",
      "source_path=\"${get_repo_root()}/lambda-email/lambda_email.py\""
    ]
  }
}

inputs = {
  function_name = "${local.env_vars.locals.environment}-lambda-email"
  runtime       = "python3.12"
  handler       = "lambda_email.lambda_handler"
  timeout       = 10
  environment_variables = {
    SES_FROM_EMAIL = "alerts@${local.env_vars.locals.route53.domain}"
    SES_TO_EMAILS = "example@mail.com"
  }

  assume_role_policy_statements = {
    account_root = {
      effect = "Allow",
      actions = ["sts:AssumeRole"],
      principals = {
        service = {
          type = "Service"
          identifiers = ["lambda.amazonaws.com"]
        }
      }
    }
  }
  attach_policy_statements = true
  policy_statements = {
    vpc_access = {
      effect = "Allow"
      actions = [
        "ses:SendEmail",
        "ses:SendRawEmail"
      ]
      resources = ["*"]
    }
  }

  tags = {
    Name = "${local.env_vars.locals.environment}-lambda-email"
  }
}