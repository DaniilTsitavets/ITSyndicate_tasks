resource "aws_lb_target_group" "task1_tg" {
  name        = "task1-tg"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "task1-tg"
  }
}

resource "aws_lb" "task1_alb" {
  name               = "task1-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public_subnet[*].id

  tags = {
    Name = "task1-alb"
  }
}

resource "aws_lb_listener" "task1_listener" {
  load_balancer_arn = aws_lb.task1_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.task1_tg.arn
  }
}
