output "estimated_monthly_cost" {
  description = "Estimated monthly cost in USD"
  value       = format("$%.2f", local.total_estimated_cost)
}

output "cost_breakdown" {
  description = "Cost breakdown by module (in USD)"
  value = {
    for module_name, cost in local.cost_estimates :
    module_name => format("$%.2f", cost)
  }
}

output "resource_summary" {
  description = "Summary of provisioned resources by category"
  value = {
    networking    = var.enable_networking ? "VPC, Subnets, Security Groups, Internet Gateway" : "disabled"
    security      = var.enable_security ? "IAM Roles, KMS Key, Secrets Manager" : "disabled"
    storage       = var.enable_storage ? "S3 Buckets, EBS Volumes" : "disabled"
    compute       = var.enable_compute ? "Lambda Functions, EC2 Instance, Auto Scaling Group" : "disabled"
    database      = var.enable_database ? (var.enable_rds ? "DynamoDB Tables, RDS Instance" : "DynamoDB Tables") : "disabled"
    messaging     = var.enable_messaging ? "SNS Topics, SQS Queues" : "disabled"
    monitoring    = var.enable_monitoring ? "CloudWatch Logs/Alarms/Dashboard, CloudTrail" : "disabled"
    api           = var.enable_api ? "API Gateway REST API" : "disabled"
    container     = var.enable_container ? "ECR Repository, ECS Cluster/Service" : "disabled"
    code_services = var.enable_code_services ? "CodeCommit, CodeBuild" : "disabled"
    orchestration = var.enable_orchestration ? "Step Functions, EventBridge" : "disabled"
    route53       = var.enable_route53 && var.domain_name != "" ? "Hosted Zone for ${var.domain_name}" : "disabled"
  }
}

output "aws_region" {
  description = "AWS region where resources are provisioned"
  value       = var.aws_region
}

output "project_name" {
  description = "Project name used for resource naming"
  value       = var.project_name
}

# Orchestration Module Outputs
output "state_machine_arn" {
  description = "Step Functions state machine ARN"
  value       = var.enable_orchestration ? module.orchestration[0].state_machine_arn : null
}

output "eventbridge_rule_names" {
  description = "List of EventBridge rule names"
  value       = var.enable_orchestration ? module.orchestration[0].eventbridge_rule_names : []
}

# Code Services Module Outputs
output "codecommit_repository_url" {
  description = "CodeCommit repository clone URL"
  value       = var.enable_code_services ? module.code_services[0].codecommit_repository_url : null
}

output "codebuild_project_name" {
  description = "CodeBuild project name"
  value       = var.enable_code_services ? module.code_services[0].codebuild_project_name : null
}

output "codepipeline_name" {
  description = "CodePipeline name"
  value       = var.enable_code_services && var.enable_codepipeline ? module.code_services[0].codepipeline_name : null
}

# Container Module Outputs
output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = var.enable_container ? module.container[0].ecr_repository_url : null
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = var.enable_container ? module.container[0].ecs_cluster_name : null
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = var.enable_container ? module.container[0].ecs_service_name : null
}

# API Module Outputs
output "api_gateway_endpoint" {
  description = "API Gateway invoke URL"
  value       = var.enable_api ? module.api[0].api_gateway_endpoint : null
}

output "api_gateway_id" {
  description = "API Gateway REST API ID"
  value       = var.enable_api ? module.api[0].api_gateway_id : null
}

# Monitoring Module Outputs
output "cloudwatch_dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = var.enable_monitoring ? module.monitoring[0].dashboard_name : null
}

output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = var.enable_monitoring ? module.monitoring[0].cloudtrail_arn : null
}

output "log_group_names" {
  description = "List of CloudWatch log group names"
  value       = var.enable_monitoring ? module.monitoring[0].log_group_names : []
}

# Messaging Module Outputs
output "sns_topic_arns" {
  description = "List of SNS topic ARNs"
  value       = var.enable_messaging ? module.messaging[0].sns_topic_arns : []
}

output "sqs_queue_urls" {
  description = "List of SQS queue URLs"
  value       = var.enable_messaging ? module.messaging[0].sqs_queue_urls : []
}

# Database Module Outputs
output "dynamodb_table_names" {
  description = "List of DynamoDB table names"
  value       = var.enable_database ? module.database[0].dynamodb_table_names : []
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = var.enable_database && var.enable_rds ? module.database[0].rds_endpoint : null
}

# Compute Module Outputs
output "lambda_function_arns" {
  description = "List of Lambda function ARNs"
  value       = var.enable_compute ? module.compute[0].lambda_function_arns : []
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = var.enable_compute ? module.compute[0].ec2_instance_id : null
}

output "ec2_instance_public_ip" {
  description = "EC2 instance public IP"
  value       = var.enable_compute ? module.compute[0].ec2_instance_public_ip : null
}

output "ec2_key_pair_name" {
  description = "EC2 SSH key pair name"
  value       = var.enable_compute ? module.compute[0].ec2_key_pair_name : null
}

output "ec2_private_key_file" {
  description = "Path to EC2 private key file (for SSH access)"
  value       = var.enable_compute ? module.compute[0].ec2_private_key_file : null
}

output "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  value       = var.enable_compute ? module.compute[0].autoscaling_group_name : null
}

# Storage Module Outputs
output "s3_bucket_names" {
  description = "List of S3 bucket names"
  value       = var.enable_storage ? module.storage[0].s3_bucket_names : []
}

output "ebs_volume_id" {
  description = "EBS volume ID"
  value       = var.enable_storage ? module.storage[0].ebs_volume_id : null
}

# Security Module Outputs
output "kms_key_id" {
  description = "KMS key ID"
  value       = var.enable_security ? module.security[0].kms_key_id : null
}

output "lambda_execution_role_arn" {
  description = "Lambda execution role ARN"
  value       = var.enable_security ? module.security[0].lambda_execution_role_arn : null
}

output "ec2_instance_profile_name" {
  description = "EC2 instance profile name"
  value       = var.enable_security ? module.security[0].ec2_instance_profile_name : null
}

output "secrets_manager_secret_arns" {
  description = "Secrets Manager secret ARNs"
  value       = var.enable_security ? module.security[0].secrets_manager_secret_arns : []
}

# Networking Module Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = var.enable_networking ? module.networking[0].vpc_id : null
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = var.enable_networking ? module.networking[0].public_subnet_ids : []
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = var.enable_networking ? module.networking[0].private_subnet_ids : []
}

output "security_group_ids" {
  description = "Map of security group IDs"
  value       = var.enable_networking ? module.networking[0].security_group_ids : {}
}

# Module-specific outputs will be added as modules are implemented

# Aggregate Resource Summary
output "infrastructure_summary" {
  description = "Complete infrastructure summary"
  value = {
    region         = var.aws_region
    project_name   = var.project_name
    estimated_cost = format("$%.2f", local.total_estimated_cost)
    modules_enabled = {
      networking    = var.enable_networking
      security      = var.enable_security
      storage       = var.enable_storage
      compute       = var.enable_compute
      database      = var.enable_database
      messaging     = var.enable_messaging
      monitoring    = var.enable_monitoring
      api           = var.enable_api
      container     = var.enable_container
      code_services = var.enable_code_services
      orchestration = var.enable_orchestration
      route53       = var.enable_route53 && var.domain_name != ""
    }
    resource_counts = {
      vpc                = var.enable_networking ? 1 : 0
      subnets            = var.enable_networking ? 4 : 0
      security_groups    = var.enable_networking ? 4 : 0
      iam_roles          = var.enable_security ? 7 : 0
      kms_keys           = var.enable_security ? 1 : 0
      secrets            = var.enable_security ? 2 : 0
      s3_buckets         = var.enable_storage ? 2 : 0
      ebs_volumes        = var.enable_storage ? 1 : 0
      lambda_functions   = var.enable_compute ? 2 : 0
      ec2_instances      = var.enable_compute ? 1 : 0
      dynamodb_tables    = var.enable_database ? 2 : 0
      rds_instances      = var.enable_database && var.enable_rds ? 1 : 0
      sns_topics         = var.enable_messaging ? 2 : 0
      sqs_queues         = var.enable_messaging ? 3 : 0
      cloudwatch_alarms  = var.enable_monitoring ? 2 : 0
      api_gateways       = var.enable_api ? 1 : 0
      ecr_repositories   = var.enable_container ? 1 : 0
      ecs_clusters       = var.enable_container ? 1 : 0
      codecommit_repos   = var.enable_code_services ? 1 : 0
      codebuild_projects = var.enable_code_services ? 1 : 0
      state_machines     = var.enable_orchestration ? 1 : 0
      eventbridge_rules  = var.enable_orchestration ? 2 : 0
      route53_zones      = var.enable_route53 && var.domain_name != "" ? 1 : 0
      vpc_endpoints      = var.enable_networking && var.enable_vpc_endpoints ? 3 : 0
    }
  }
}

# Route53 Outputs
output "route53_hosted_zone_id" {
  description = "Route53 hosted zone ID"
  value       = var.enable_route53 && var.domain_name != "" ? module.route53[0].hosted_zone_id : null
}

output "route53_name_servers" {
  description = "Route53 hosted zone name servers"
  value       = var.enable_route53 && var.domain_name != "" ? module.route53[0].name_servers : []
}

output "route53_zone_arn" {
  description = "Route53 hosted zone ARN"
  value       = var.enable_route53 && var.domain_name != "" ? module.route53[0].zone_arn : null
}

# VPC Endpoint Outputs
output "vpc_endpoint_s3_id" {
  description = "S3 VPC Endpoint ID"
  value       = var.enable_networking ? module.networking[0].vpc_endpoint_s3_id : null
}

output "vpc_endpoint_dynamodb_id" {
  description = "DynamoDB VPC Endpoint ID"
  value       = var.enable_networking ? module.networking[0].vpc_endpoint_dynamodb_id : null
}

output "vpc_endpoint_lambda_id" {
  description = "Lambda VPC Endpoint ID"
  value       = var.enable_networking ? module.networking[0].vpc_endpoint_lambda_id : null
}
