output "api_gateway_id" {
  description = "API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.main.id
}

output "api_gateway_name" {
  description = "API Gateway REST API name"
  value       = aws_api_gateway_rest_api.main.name
}

output "api_gateway_endpoint" {
  description = "API Gateway invoke URL"
  value       = aws_api_gateway_stage.main.invoke_url
}

output "api_gateway_stage_name" {
  description = "API Gateway stage name"
  value       = aws_api_gateway_stage.main.stage_name
}

output "api_gateway_execution_arn" {
  description = "API Gateway execution ARN"
  value       = aws_api_gateway_rest_api.main.execution_arn
}

output "estimated_cost" {
  description = "Estimated monthly cost for API resources"
  value       = 0 # API Gateway free tier (1M requests)
}
