#!/usr/bin/env bash

PROJECT_ROOT=$(cd "$(pwd | sed -E 's|(.*)/\.terragrunt-cache/.*|\1|')" && pwd)
LAMBDA_DIR="$PROJECT_ROOT/../lambda"

LAMBDA_ARN="$(terragrunt output -raw lambda_function_arn --working-dir "$LAMBDA_DIR")"
API_GATEWAY_ID="$("$TG_CTX_TF_PATH" output -raw api_id)"
AWS_REGION="${AWS_REGION:-eu-north-1}"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
STATEMENT_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')

EXISTS=$(aws lambda get-policy \
  --function-name "$LAMBDA_ARN" \
  --query "Policy" \
  --output text 2>/dev/null | grep -F "${API_GATEWAY_ID}/*/*/") || true

if [[ -n "$EXISTS" ]]; then
  echo "Permission already exists."
else
  echo "Add permission fpr apigateway."
  aws lambda add-permission \
    --statement-id "$STATEMENT_ID" \
    --action lambda:InvokeFunction \
    --function-name "$LAMBDA_ARN" \
    --principal apigateway.amazonaws.com \
    --source-arn "arn:aws:execute-api:${AWS_REGION}:${AWS_ACCOUNT_ID}:${API_GATEWAY_ID}/*/*/"
fi