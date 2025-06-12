resource "aws_alb_target_group" "django_app_tg" {
  name     = "django-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_alb_target_group_attachment" "django_app_attachments" {
  count = length(var.ec2_instance_ids)

  target_group_arn = aws_alb_target_group.django_app_tg.arn
  target_id        = var.ec2_instance_ids[count.index]
  port             = 80
}

resource "aws_lb" "django_alb" {
  name               = "django-alb"
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnets

  tags = {
    Name = "task3-django-alb"
  }
}

resource "aws_lb_listener" "django_alb_listener" {
  load_balancer_arn = aws_lb.django_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.django_app_tg.arn
  }
}