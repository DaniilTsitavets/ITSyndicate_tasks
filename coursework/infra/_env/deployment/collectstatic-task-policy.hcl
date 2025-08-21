locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  tags = local.env_vars.locals.tags
}

terraform {
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-policy?version=6.0.0"
}

dependency "s3-bucket" {
  config_path = find_in_parent_folders("s3-bucket")
}

inputs = {
  name_prefix = "${local.env_vars.locals.environment}-collectstatic-"
  path        = "/"
  description = "Policy for collectstatic task - S3 write access"

  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:DeleteObject"
          ],
          "Resource": [
            "arn:aws:s3:::${dependency.s3-bucket.outputs.s3_bucket_id}",
            "arn:aws:s3:::${dependency.s3-bucket.outputs.s3_bucket_id}/*"
          ]
        }
      ]
    }
  EOF

  tags = local.tags
}