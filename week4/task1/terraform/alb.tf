resource "aws_alb_target_group" "django-app-tg" {
  name     = "django-app-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.django_vpc.id

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
  count = length(aws_instance.django_app)

  target_group_arn = aws_alb_target_group.django-app-tg.arn
  target_id        = aws_instance.django_app[count.index].id
  port             = 8000
}

resource "aws_lb" "django_alb" {
  name               = "django-alb"
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.django_public_subnet[*].id
}

resource "aws_lb_listener" "django_alb_listener" {
  load_balancer_arn = aws_lb.django_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.django-app-tg.arn
  }
}