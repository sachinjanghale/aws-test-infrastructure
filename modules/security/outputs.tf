output "kms_key_id" {
  description = "KMS key ID"
  value       = aws_kms_key.main.key_id
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = aws_kms_key.main.arn
}

output "kms_key_alias" {
  description = "KMS key alias"
  value       = aws_kms_alias.main.name
}

output "lambda_execution_role_arn" {
  description = "Lambda execution role ARN"
  value       = aws_iam_role.lambda_execution.arn
}

output "lambda_execution_role_name" {
  description = "Lambda execution role name"
  value       = aws_iam_role.lambda_execution.name
}

output "ec2_instance_profile_arn" {
  description = "EC2 instance profile ARN"
  value       = aws_iam_instance_profile.ec2.arn
}

output "ec2_instance_profile_name" {
  description = "EC2 instance profile name"
  value       = aws_iam_instance_profile.ec2.name
}

output "ec2_instance_role_arn" {
  description = "EC2 instance role ARN"
  value       = aws_iam_role.ec2_instance.arn
}

output "ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  value       = aws_iam_role.ecs_task_execution.name
}

output "ecs_task_role_arn" {
  description = "ECS task role ARN"
  value       = aws_iam_role.ecs_task.arn
}

output "ecs_task_role_name" {
  description = "ECS task role name"
  value       = aws_iam_role.ecs_task.name
}

output "step_functions_role_arn" {
  description = "Step Functions role ARN"
  value       = aws_iam_role.step_functions.arn
}

output "step_functions_role_name" {
  description = "Step Functions role name"
  value       = aws_iam_role.step_functions.name
}

output "codebuild_role_arn" {
  description = "CodeBuild role ARN"
  value       = aws_iam_role.codebuild.arn
}

output "codebuild_role_name" {
  description = "CodeBuild role name"
  value       = aws_iam_role.codebuild.name
}

output "secrets_manager_secret_arns" {
  description = "List of Secrets Manager secret ARNs"
  value = [
    aws_secretsmanager_secret.db_credentials.arn,
    aws_secretsmanager_secret.api_keys.arn
  ]
}

output "db_credentials_secret_arn" {
  description = "Database credentials secret ARN"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "api_keys_secret_arn" {
  description = "API keys secret ARN"
  value       = aws_secretsmanager_secret.api_keys.arn
}

output "estimated_cost" {
  description = "Estimated monthly cost for security resources"
  value       = 0.80 # 2 secrets * $0.40/month
}

output "glue_role_arn" {
  description = "Glue service role ARN"
  value       = aws_iam_role.glue.arn
}

output "config_role_arn" {
  description = "AWS Config service role ARN"
  value       = aws_iam_role.config.arn
}

output "iot_role_arn" {
  description = "IoT service role ARN"
  value       = aws_iam_role.iot.arn
}

output "firehose_role_arn" {
  description = "Kinesis Firehose service role ARN"
  value       = aws_iam_role.firehose.arn
}

output "appsync_role_arn" {
  description = "AppSync service role ARN"
  value       = aws_iam_role.appsync.arn
}

output "batch_service_role_arn" {
  description = "Batch service role ARN"
  value       = aws_iam_role.batch_service.arn
}

output "batch_execution_role_arn" {
  description = "Batch execution role ARN"
  value       = aws_iam_role.batch_execution.arn
}

output "rds_monitoring_role_arn" {
  description = "RDS enhanced monitoring role ARN"
  value       = aws_iam_role.rds_monitoring.arn
}

output "rds_master_secret_arn" {
  description = "RDS master credentials secret ARN"
  value       = aws_secretsmanager_secret.rds_master.arn
}

output "lambda_db_config_secret_arn" {
  description = "Lambda DB config secret ARN"
  value       = aws_secretsmanager_secret.lambda_db_config.arn
}

output "total_secrets_count" {
  description = "Total number of Secrets Manager secrets"
  value       = 5 # db_credentials, api_keys, rds_master, lambda_db_config + 1 for future
}
