module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name   = "alb"
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "ex-instance"
      }
    }
  }


  target_groups = {
    ex-instance = {
      name_prefix = "web-"
      protocol    = "HTTP"
      port        = 80
      target_type = "instance"
      target_id = module.web.id
    }
  }

  tags = {
    Environment = "dev"
  }
}