output "log_group_names" {
  description = "List of CloudWatch log group names"
  value = concat(
    aws_cloudwatch_log_group.lambda[*].name,
    [aws_cloudwatch_log_group.ec2.name]
  )
}

output "alarm_names" {
  description = "List of CloudWatch alarm names"
  value = concat(
    aws_cloudwatch_metric_alarm.ec2_cpu[*].alarm_name,
    aws_cloudwatch_metric_alarm.lambda_errors[*].alarm_name
  )
}

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "dashboard_arn" {
  description = "CloudWatch dashboard ARN"
  value       = aws_cloudwatch_dashboard.main.dashboard_arn
}

output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_name" {
  description = "CloudTrail name"
  value       = aws_cloudtrail.main.name
}

output "cloudtrail_s3_bucket" {
  description = "S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail.id
}

output "estimated_cost" {
  description = "Estimated monthly cost for monitoring resources"
  value       = 0.223 # CloudWatch alarms + CloudTrail storage
}
