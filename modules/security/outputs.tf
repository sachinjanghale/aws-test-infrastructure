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
