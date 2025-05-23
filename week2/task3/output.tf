output "cdn_dns_name" {
  value = aws_cloudfront_distribution.demo_cdn.domain_name
}
