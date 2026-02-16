output "dynamodb_table_names" {
  description = "List of DynamoDB table names"
  value = [
    aws_dynamodb_table.simple.name,
    aws_dynamodb_table.composite.name
  ]
}

output "dynamodb_table_arns" {
  description = "List of DynamoDB table ARNs"
  value = [
    aws_dynamodb_table.simple.arn,
    aws_dynamodb_table.composite.arn
  ]
}

output "dynamodb_simple_table_name" {
  description = "Simple DynamoDB table name"
  value       = aws_dynamodb_table.simple.name
}

output "dynamodb_simple_table_arn" {
  description = "Simple DynamoDB table ARN"
  value       = aws_dynamodb_table.simple.arn
}

output "dynamodb_composite_table_name" {
  description = "Composite DynamoDB table name"
  value       = aws_dynamodb_table.composite.name
}

output "dynamodb_composite_table_arn" {
  description = "Composite DynamoDB table ARN"
  value       = aws_dynamodb_table.composite.arn
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = var.enable_rds ? aws_db_instance.main[0].endpoint : null
}

output "rds_instance_id" {
  description = "RDS instance ID"
  value       = var.enable_rds ? aws_db_instance.main[0].id : null
}

output "rds_instance_arn" {
  description = "RDS instance ARN"
  value       = var.enable_rds ? aws_db_instance.main[0].arn : null
}

output "rds_database_name" {
  description = "RDS database name"
  value       = var.enable_rds ? aws_db_instance.main[0].db_name : null
}

output "estimated_cost" {
  description = "Estimated monthly cost for database resources"
  value       = var.enable_rds ? 14.71 : 0 # DynamoDB free tier, RDS: $12.41 + $2.30
}
