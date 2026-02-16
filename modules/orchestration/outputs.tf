output "state_machine_arn" {
  description = "Step Functions state machine ARN"
  value       = aws_sfn_state_machine.main.arn
}

output "state_machine_name" {
  description = "Step Functions state machine name"
  value       = aws_sfn_state_machine.main.name
}

output "eventbridge_rule_names" {
  description = "List of EventBridge rule names"
  value = [
    aws_cloudwatch_event_rule.scheduled_6h.name,
    aws_cloudwatch_event_rule.scheduled_daily.name
  ]
}

output "eventbridge_rule_arns" {
  description = "List of EventBridge rule ARNs"
  value = [
    aws_cloudwatch_event_rule.scheduled_6h.arn,
    aws_cloudwatch_event_rule.scheduled_daily.arn
  ]
}

output "estimated_cost" {
  description = "Estimated monthly cost for orchestration resources"
  value       = 0 # Step Functions and EventBridge are free tier
}
