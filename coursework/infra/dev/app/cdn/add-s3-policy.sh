#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT=$(cd "$(pwd | sed -E 's|(.*)/\.terragrunt-cache/.*|\1|')" && pwd)
S3_DIR="$PROJECT_ROOT/../s3-bucket"
CF_DIR="$PROJECT_ROOT"

BUCKET_ARN="$(terragrunt output -raw s3_bucket_arn --working-dir "$S3_DIR")"
BUCKET_NAME="$(terragrunt output -raw s3_bucket_id --working-dir "$S3_DIR")"
CF_ARN="$(terragrunt output -raw cloudfront_distribution_arn --working-dir "$CF_DIR")"
EXISTS=$(aws s3api get-bucket-policy \
  --bucket "$BUCKET_NAME" \
  --query "Policy" \
  --output text 2>/dev/null | grep -F "$CF_ARN") || true

if [[ -n "$EXISTS" ]]; then
  echo "Policy for $CF_ARN already exists, skipping."
  exit 0
fi

POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudFrontServicePrincipalReadOnly",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudfront.amazonaws.com"
      },
      "Action": "s3:GetObject",
      "Resource": "${BUCKET_ARN}/*",
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": "$CF_ARN"
        }
      }
    }
  ]
}
EOF
)

aws s3api put-bucket-policy \
  --bucket "$BUCKET_NAME" \
  --policy "$POLICY"

echo "Policy for $BUCKET_NAME was created."