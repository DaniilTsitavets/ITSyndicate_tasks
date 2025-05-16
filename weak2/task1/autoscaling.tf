resource "aws_launch_template" "demo_lt" {
  name_prefix   = "demo-lt-"
  image_id      = "ami-0c1ac8a41498c1a9c"
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.demo_sg.id]

  user_data = base64encode(file("userdata.sh"))

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "demo_asg" {
  desired_capacity     = 1
  max_size             = 1
  min_size             = 3
  vpc_zone_identifier  = data.aws_subnets.default.ids
  target_group_arns    = [aws_lb_target_group.demo_tg.arn]

  launch_template {
    id      = aws_launch_template.demo_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "demo-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
