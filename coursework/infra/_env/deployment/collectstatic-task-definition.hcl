locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  subdomain = contains(["staging", "prod"], local.env_vars.locals.environment) ? "" : "${local.env_vars.locals.environment}."
  tags      = local.env_vars.locals.tags
}

terraform {
  source = "tfr:///terraform-aws-modules/ecs/aws//modules/service?version=6.2.1"
}

dependency "ecr" {
  config_path = find_in_parent_folders("ecr")
}

dependency "vpc" {
  config_path = find_in_parent_folders("vpc")
}

dependency "collectstatic-task-iam-role" {
  config_path = find_in_parent_folders("collectstatic-task-iam-role")
}

dependency "s3-bucket" {
  config_path = find_in_parent_folders("s3-bucket")
}

inputs = {
  name                      = "${local.env_vars.locals.environment}-collectstatic-task-definition"
  create_service            = false
  create_task_exec_iam_role = true
  create_task_exec_policy   = true
  create_iam_role           = false
  create_tasks_iam_role     = false

  tasks_iam_role_arn = dependency.collectstatic-task-iam-role.outputs.arn


  runtime_platform = {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = {
    collectstatic = {
      image     = "${dependency.ecr.outputs.repository_url}:latest"
      cpu       = 1024
      memory    = 2028
      essential = true
      command = ["python", "manage.py", "collectstatic", "--noinput"]
      environment = [
        {
          name  = "STATIC_URL"
          value = "${local.subdomain}${local.env_vars.locals.route53.domain}"
        },
        {
          name  = "USE_S3"
          value = "true"
        },
        {
          name  = "AWS_STORAGE_BUCKET_NAME"
          value = "${dependency.s3-bucket.outputs.s3_bucket_id}"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/aws/ecs/${local.env_vars.locals.environment}-collectstatic-task-definition/collectstatic"
          awslogs-region        = "eu-north-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  }

  subnet_ids = dependency.vpc.outputs.public_subnets
  security_group_name = "${local.env_vars.locals.environment}-collectstatic-task-definition-sg"
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  tags = local.tags
}