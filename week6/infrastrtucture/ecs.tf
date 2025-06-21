resource "aws_ecs_cluster" "task1_cluster" {
  name = "task1_cluster"
}

resource "aws_cloudwatch_log_group" "django_logs" {
  name              = "/ecs/sample-django"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "sample_django_task_definition" {
  depends_on = [aws_cloudwatch_log_group.django_logs]
  family             = "sample-django"
  network_mode       = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                = "256"
  memory             = "512"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "migrations"
      image     = aws_ecr_repository.task1_ecr.repository_url
      essential = false
      command = ["python", "manage.py", "migrate"]
      environment = [
        { name = "DB_NAME", value = data.aws_ssm_parameter.db_name.value },
        { name = "DB_USER", value = data.aws_ssm_parameter.db_username.value },
        { name = "DB_HOST", value = aws_db_instance.db.address },
        { name = "DB_PORT", value = "5432" },
        { name = "SECRET_KEY", value = data.aws_ssm_parameter.secret_key.value },
        {
          name  = "DJANGO_ALLOWED_HOSTS"
          value = "*"
        },
        {
          name  = "DATABASE_URL",
          value = "postgres://${data.aws_ssm_parameter.db_username.value}:${data.aws_ssm_parameter.db_password.value}@${aws_db_instance.db.address}:5432/${data.aws_ssm_parameter.db_name.value}"
        }
      ]
      secrets = [
        {
          name      = "DB_PASSWORD",
          valueFrom = data.aws_ssm_parameter.db_password.arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/sample-django"
          awslogs-region        = "eu-north-1"
          awslogs-stream-prefix = "migrations"
        }
      }
    },
    {
      name      = "django"
      image     = aws_ecr_repository.task1_ecr.repository_url
      essential = true
      command = [
        "sh", "-c", "python manage.py collectstatic --noinput && gunicorn mysite.wsgi:application --bind 0.0.0.0:8000"
      ]
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]
      environment = [
        { name = "DB_NAME", value = data.aws_ssm_parameter.db_name.value },
        { name = "DB_USER", value = data.aws_ssm_parameter.db_username.value },
        { name = "DB_HOST", value = aws_db_instance.db.address },
        { name = "DB_PORT", value = "5432" },
        { name = "SECRET_KEY", value = data.aws_ssm_parameter.secret_key.value },
        {
          name  = "DJANGO_ALLOWED_HOSTS"
          value = "*"
        },
        {
          name  = "DATABASE_URL",
          value = "postgres://${data.aws_ssm_parameter.db_username.value}:${data.aws_ssm_parameter.db_password.value}@${aws_db_instance.db.address}:5432/${data.aws_ssm_parameter.db_name.value}"
        }
      ]
      secrets = [
        {
          name      = "DB_PASSWORD",
          valueFrom = data.aws_ssm_parameter.db_password.arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/sample-django"
          awslogs-region        = "eu-north-1"
          awslogs-stream-prefix = "django"
        }
      }
      dependsOn = [
        {
          containerName = "migrations"
          condition     = "SUCCESS"
        }
      ]
    }
  ])
}


resource "aws_ecs_service" "django_service" {
  name            = "sample-django-service"
  cluster         = aws_ecs_cluster.task1_cluster.name
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.sample_django_task_definition.arn
  desired_count   = 1

  network_configuration {
    subnets          = aws_subnet.public_subnet[*].id
    assign_public_ip = true
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.task1_tg.arn
    container_name   = "django"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.task1_listener]
}

