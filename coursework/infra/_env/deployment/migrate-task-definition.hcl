locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  db_username = local.env_vars.locals.username
  db_name     = local.env_vars.locals.db_name
  tags        = local.env_vars.locals.tags
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

dependency "db" {
  config_path = find_in_parent_folders("db")
}

dependency "secret-db" {
  config_path = find_in_parent_folders("secret-db")
}

dependency "migrate-sg" {
  config_path = find_in_parent_folders("migrate-sg")
}

inputs = {
  name                      = "${local.env_vars.locals.environment}-migrate-task-definition"
  create_service            = false
  create_iam_role           = false
  create_task_exec_iam_role = true
  create_task_exec_policy   = true
  create_security_group     = false

  runtime_platform = {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = {
    migrate = {
      image     = "${dependency.ecr.outputs.repository_url}:latest"
      cpu       = 1024
      memory    = 2048
      essential = true
      command = ["python", "manage.py", "migrate"]
      environment = [
        {
          name  = "DATABASE_URL"
          value = "postgres://${local.db_username}:${dependency.secret-db.outputs.secret_string}@${dependency.db.outputs.db_instance_address}:5432/${local.db_name}"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/aws/ecs/${local.env_vars.locals.environment}-migrate-task-definition/migrate"
          awslogs-region        = "eu-north-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  }

  tags               = local.tags
}