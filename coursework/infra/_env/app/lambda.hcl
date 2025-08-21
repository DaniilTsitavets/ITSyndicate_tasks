locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  db_username = local.env_vars.locals.username
  db_name     = local.env_vars.locals.db_name
  subdomain   = contains(["staging", "prod"], local.env_vars.locals.environment) ? "" : "${local.env_vars.locals.environment}."
}

terraform {
  source = "tfr:///terraform-aws-modules/lambda/aws?version=8.0.1"
}

dependency "vpc" {
  config_path = find_in_parent_folders("vpc")
}

dependency "db" {
  config_path = find_in_parent_folders("db")
}

dependency "lambda-sg" {
  config_path = find_in_parent_folders("lambda-sg")
}

dependency "s3-bucket" {
  config_path = find_in_parent_folders("s3-bucket")
}

dependency "secret-db" {
  config_path = find_in_parent_folders("secret-db")
}

dependency "ecr" {
  config_path = find_in_parent_folders("ecr")
}

inputs = {
  function_name  = "${local.env_vars.locals.environment}-lambda"
  create_package = false
  package_type   = "Image"
  image_uri      = "${dependency.ecr.outputs.repository_url}:latest"
  timeout        = 10
  vpc_subnet_ids = dependency.vpc.outputs.public_subnets
  vpc_security_group_ids = [dependency.lambda-sg.outputs.security_group_id]

  environment_variables = {
    AWS_LWA_PORT            = "8000"
    AWS_LAMBDA_EXEC_WRAPPER = "/opt/bootstrap"
    DATABASE_URL            = "postgres://${local.db_username}:${dependency.secret-db.outputs.secret_string}@${dependency.db.outputs.db_instance_address}:5432/${local.db_name}"
    USE_S3                  = true
    STATIC_URL              = "https://${local.subdomain}${local.env_vars.locals.route53.domain}/static/"
    STATICFILES_STORAGE     = "storages.backends.s3boto3.S3Boto3Storage"
    DJANGO_ALLOWED_HOSTS    = "*"
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
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ]
      resources = ["*"]
    },
    ecr_access = {
      effect = "Allow",
      actions = [
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer"
      ]
      resources = [dependency.ecr.outputs.repository_arn]
    }
  }

  tags = {
    Name = "${local.env_vars.locals.environment}-lambda"
  }
}