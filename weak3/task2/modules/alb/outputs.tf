output "target_group_arn" {
  value = aws_lb_target_group.demo_tg.arn
}

output "alb_dns" {
  value = aws_lb.demo_alb.dns_name
}