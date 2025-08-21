locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "tfr:///terraform-aws-modules/cloudwatch/aws//modules/metric-alarm?version=5.7.1"
}

dependency "sns" {
  config_path = find_in_parent_folders("sns")
}

inputs = {
  alarm_name          = "${local.env_vars.locals.environment}-cloudwatch-5xx-alarm"
  alarm_description   = "Any 5XX will trigger alarm and send log to SNS"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 0
  period              = 60
  unit                = "Count"

  namespace   = "AWS/Lambda"
  metric_name = "Url5xxCount"
  statistic   = "Sum"
  dimensions = {
    FunctionName = "${local.env_vars.locals.environment}-lambda"
  }

  alarm_actions = ["${dependency.sns.outputs.topic_arn}"]
}