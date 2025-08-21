locals {
  environment = "dev"
  username    = "masteruser"
  db_name     = "DB${local.environment}"
  route53 = {
    domain           = ""
    hosted_zone_id   = "Z07484993CJEBX0BD8VOJ"
    hosted_zone_name = ""
  }
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}