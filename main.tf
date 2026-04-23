# AWS Test Infrastructure - Root Configuration
# This configuration orchestrates all modules for testing the infrasyn.app migration tool

# Data source to get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# Data source for current account
data "aws_caller_identity" "current" {}

# Local variables
locals {
  # Use provided AZs or default to first 2 in region
  availability_zones = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 2)

  # Common tags for all resources
  common_tags = {
    Project     = var.project_name
    Environment = "test"
    ManagedBy   = "terraform"
    CostCenter  = "testing"
  }
}

# Security Module (must be first - provides IAM roles for other modules)
module "security" {
  source = "./modules/security"
  count  = var.enable_security ? 1 : 0

  project_name         = var.project_name
  rds_endpoint         = "placeholder-update-after-apply"
  rds_identifier       = "placeholder-update-after-apply"
  elasticache_endpoint = "placeholder-update-after-apply"
  common_tags          = local.common_tags
}

# Networking Module
module "networking" {
  source = "./modules/networking"
  count  = var.enable_networking ? 1 : 0

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = local.availability_zones
  enable_nat_gateway   = var.enable_nat_gateway
  enable_vpc_endpoints = var.enable_vpc_endpoints
  common_tags          = local.common_tags
}

# Storage Module
module "storage" {
  source = "./modules/storage"
  count  = var.enable_storage ? 1 : 0

  project_name      = var.project_name
  kms_key_id        = var.enable_security ? module.security[0].kms_key_arn : ""
  availability_zone = local.availability_zones[0]
  common_tags       = local.common_tags
}

# Compute Module
module "compute" {
  source = "./modules/compute"
  count  = var.enable_compute && var.enable_networking && var.enable_security && var.enable_storage ? 1 : 0

  project_name              = var.project_name
  vpc_id                    = module.networking[0].vpc_id
  public_subnet_ids         = module.networking[0].public_subnet_ids
  security_group_id         = module.networking[0].security_group_web_id
  lambda_execution_role_arn = module.security[0].lambda_execution_role_arn
  ec2_instance_profile_name = module.security[0].ec2_instance_profile_name
  ebs_volume_id             = module.storage[0].ebs_volume_id
  enable_messaging          = var.enable_messaging
  sqs_queue_arn             = var.enable_messaging ? module.messaging[0].sqs_standard_queue_arn : null
  sqs_dlq_arn               = var.enable_messaging ? module.messaging[0].sqs_dlq_arn : null

  # Secrets wiring
  db_secret_arn       = module.security[0].db_credentials_secret_arn
  api_keys_secret_arn = module.security[0].api_keys_secret_arn

  # RDS endpoint for Lambda env var
  rds_endpoint = var.enable_database && var.enable_rds ? module.database[0].rds_address : ""

  # DynamoDB and S3 for Lambda env vars
  dynamodb_table_name = var.enable_database ? module.database[0].dynamodb_simple_table_name : ""
  s3_bucket_name      = module.storage[0].s3_versioned_bucket_name

  # VPC config for Python Lambda (private subnets)
  private_subnet_ids       = module.networking[0].private_subnet_ids
  lambda_security_group_id = module.networking[0].security_group_lambda_id

  # S3 EventBridge trigger
  enable_s3_trigger = var.enable_storage

  common_tags = local.common_tags

  depends_on = [module.networking, module.security, module.storage, module.messaging, module.database]
}

# Database Module
module "database" {
  source = "./modules/database"
  count  = var.enable_database ? 1 : 0

  project_name            = var.project_name
  enable_rds              = var.enable_rds && var.enable_networking
  vpc_id                  = var.enable_networking ? module.networking[0].vpc_id : ""
  private_subnet_ids      = var.enable_networking ? module.networking[0].private_subnet_ids : []
  security_group_id       = var.enable_networking ? module.networking[0].security_group_database_id : ""
  kms_key_arn             = var.enable_security ? module.security[0].kms_key_arn : ""
  rds_monitoring_role_arn = var.enable_security ? module.security[0].rds_monitoring_role_arn : ""
  rds_secret_arn          = var.enable_security ? module.security[0].db_credentials_secret_arn : ""
  sns_topic_arn           = var.enable_messaging ? module.messaging[0].sns_standard_topic_arn : ""
  enable_sns_subscription = var.enable_messaging
  db_username             = var.db_username
  db_password             = var.db_password
  common_tags             = local.common_tags

  depends_on = [module.networking, module.security, module.messaging]
}

# Messaging Module
module "messaging" {
  source = "./modules/messaging"
  count  = var.enable_messaging ? 1 : 0

  project_name = var.project_name
  kms_key_id   = var.enable_security ? module.security[0].kms_key_id : ""
  common_tags  = local.common_tags

  depends_on = [module.security]
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"
  count  = var.enable_monitoring ? 1 : 0

  project_name          = var.project_name
  lambda_function_names = var.enable_compute ? module.compute[0].lambda_function_names : []
  ec2_instance_ids      = var.enable_compute ? [module.compute[0].ec2_instance_id] : []
  sns_topic_arn         = var.enable_messaging ? module.messaging[0].sns_standard_topic_arn : ""
  common_tags           = local.common_tags

  depends_on = [module.compute, module.messaging]
}

# API Module
module "api" {
  source = "./modules/api"
  count  = var.enable_api && var.enable_compute ? 1 : 0

  project_name = var.project_name
  aws_region   = var.aws_region
  lambda_function_arns = {
    python = module.compute[0].python_lambda_arn
    nodejs = module.compute[0].nodejs_lambda_arn
  }
  lambda_function_names = {
    python = module.compute[0].python_lambda_name
    nodejs = module.compute[0].nodejs_lambda_name
  }
  api_gateway_role_arn = var.enable_security ? module.security[0].lambda_execution_role_arn : ""
  enable_vpc_link      = var.enable_vpc_link
  nlb_arn              = ""
  common_tags          = local.common_tags

  depends_on = [module.compute]
}

# Container Module
module "container" {
  source = "./modules/container"
  count  = var.enable_container && var.enable_networking && var.enable_security ? 1 : 0

  project_name                = var.project_name
  vpc_id                      = module.networking[0].vpc_id
  public_subnet_ids           = module.networking[0].public_subnet_ids
  security_group_id           = module.networking[0].security_group_ecs_id
  ecs_task_execution_role_arn = module.security[0].ecs_task_execution_role_arn
  ecs_task_role_arn           = module.security[0].ecs_task_role_arn
  kms_key_arn                 = module.security[0].kms_key_arn

  # Wire secrets to ECS containers
  db_secret_arn       = module.security[0].db_credentials_secret_arn
  api_keys_secret_arn = module.security[0].api_keys_secret_arn

  common_tags = local.common_tags

  depends_on = [module.networking, module.security]
}

# Code Services Module
module "code_services" {
  source = "./modules/code_services"
  count  = var.enable_code_services && var.enable_storage && var.enable_security ? 1 : 0

  project_name            = var.project_name
  enable_codepipeline     = var.enable_codepipeline
  s3_artifact_bucket_name = module.storage[0].s3_versioned_bucket_name
  codebuild_role_arn      = module.security[0].codebuild_role_arn
  common_tags             = local.common_tags

  depends_on = [module.storage, module.security]
}

# Orchestration Module
module "orchestration" {
  source = "./modules/orchestration"
  count  = var.enable_orchestration && var.enable_compute && var.enable_security ? 1 : 0

  project_name           = var.project_name
  lambda_function_arns   = module.compute[0].lambda_function_arns
  step_function_role_arn = module.security[0].step_functions_role_arn
  common_tags            = local.common_tags

  depends_on = [module.compute, module.security]
}

# Route53 Module
module "route53" {
  source = "./modules/route53"
  count  = var.enable_route53 && var.domain_name != "" ? 1 : 0

  project_name = var.project_name
  domain_name  = var.domain_name
  common_tags  = local.common_tags
}

# SSM Parameter Store Module
module "ssm" {
  source = "./modules/ssm"
  count  = var.enable_ssm ? 1 : 0

  project_name = var.project_name
  kms_key_id   = var.enable_security ? module.security[0].kms_key_id : ""
  common_tags  = local.common_tags
}

# EIP and ENI Module
module "eip" {
  source = "./modules/eip"
  count  = var.enable_eip && var.enable_networking ? 1 : 0

  project_name      = var.project_name
  ec2_instance_id   = var.enable_compute ? module.compute[0].ec2_instance_id : ""
  enable_ec2_eip    = false # EC2 ID is computed, enable after first apply
  subnet_id         = module.networking[0].public_subnet_ids[0]
  security_group_id = module.networking[0].security_group_web_id
  common_tags       = local.common_tags

  depends_on = [module.networking, module.compute]
}

# SES Module
module "ses" {
  source = "./modules/ses"
  count  = var.enable_ses ? 1 : 0

  project_name   = var.project_name
  ses_email      = var.ses_email
  domain_name    = var.domain_name
  s3_bucket_name = var.enable_storage ? module.storage[0].s3_versioned_bucket_name : ""
  common_tags    = local.common_tags

  depends_on = [module.storage]
}

# X-Ray Module
module "xray" {
  source = "./modules/xray"
  count  = var.enable_xray ? 1 : 0

  project_name = var.project_name
  common_tags  = local.common_tags
}

# Cognito Module
module "cognito" {
  source = "./modules/cognito"
  count  = var.enable_cognito ? 1 : 0

  project_name = var.project_name
  common_tags  = local.common_tags
}

# EFS Module
module "efs" {
  source = "./modules/efs"
  count  = var.enable_efs && var.enable_networking ? 1 : 0

  project_name      = var.project_name
  kms_key_arn       = var.enable_security ? module.security[0].kms_key_arn : ""
  subnet_ids        = module.networking[0].private_subnet_ids
  security_group_id = module.networking[0].security_group_web_id
  common_tags       = local.common_tags

  depends_on = [module.networking, module.security]
}

# Kinesis Module
module "kinesis" {
  source = "./modules/kinesis"
  count  = var.enable_kinesis && var.enable_security && var.enable_storage ? 1 : 0

  project_name      = var.project_name
  firehose_role_arn = module.security[0].firehose_role_arn
  s3_bucket_arn     = module.storage[0].s3_versioned_bucket_arn
  common_tags       = local.common_tags

  depends_on = [module.security, module.storage]
}

# WAF Module
module "waf" {
  source = "./modules/waf"
  count  = var.enable_waf && var.enable_monitoring ? 1 : 0

  project_name             = var.project_name
  cloudwatch_log_group_arn = module.monitoring[0].waf_log_group_arn
  common_tags              = local.common_tags

  depends_on = [module.monitoring]
}

# CloudFront Module (Global)
module "cloudfront" {
  source = "./modules/cloudfront"
  count  = var.enable_cloudfront && var.enable_storage ? 1 : 0

  project_name     = var.project_name
  s3_bucket_domain = module.storage[0].s3_versioned_bucket_domain
  common_tags      = local.common_tags

  depends_on = [module.storage]
}

# CodeDeploy Module
module "codedeploy" {
  source = "./modules/codedeploy"
  count  = var.enable_codedeploy ? 1 : 0

  project_name = var.project_name
  common_tags  = local.common_tags
}

# AWS Config Module
module "config" {
  source = "./modules/config"
  count  = var.enable_config && var.enable_security && var.enable_storage ? 1 : 0

  project_name    = var.project_name
  config_role_arn = module.security[0].config_role_arn
  s3_bucket_name  = module.storage[0].s3_versioned_bucket_name
  common_tags     = local.common_tags

  depends_on = [module.security, module.storage]
}

# Resource Groups Module
module "resourcegroups" {
  source = "./modules/resourcegroups"
  count  = var.enable_resourcegroups ? 1 : 0

  project_name = var.project_name
  common_tags  = local.common_tags
}

# IoT Module
module "iot" {
  source = "./modules/iot"
  count  = var.enable_iot && var.enable_security && var.enable_compute ? 1 : 0

  project_name        = var.project_name
  iot_role_arn        = module.security[0].iot_role_arn
  lambda_function_arn = module.compute[0].python_lambda_arn
  common_tags         = local.common_tags

  depends_on = [module.security, module.compute]
}

# Glue Module
module "glue" {
  source = "./modules/glue"
  count  = var.enable_glue && var.enable_security && var.enable_storage ? 1 : 0

  project_name   = var.project_name
  glue_role_arn  = module.security[0].glue_role_arn
  s3_bucket_name = module.storage[0].s3_versioned_bucket_name
  common_tags    = local.common_tags

  depends_on = [module.security, module.storage]
}

# ECR Public Module (Global - needs us-east-1 provider)
module "ecrpublic" {
  source = "./modules/ecrpublic"
  count  = var.enable_ecrpublic ? 1 : 0

  project_name = var.project_name
  common_tags  = local.common_tags

  providers = {
    aws = aws.us_east_1
  }
}

# Access Analyzer Module
module "accessanalyzer" {
  source = "./modules/accessanalyzer"
  count  = var.enable_accessanalyzer ? 1 : 0

  project_name = var.project_name
  common_tags  = local.common_tags
}

# ACM Module
module "acm" {
  source = "./modules/acm"
  count  = var.enable_acm && var.domain_name != "" ? 1 : 0

  project_name = var.project_name
  domain_name  = var.domain_name
  common_tags  = local.common_tags
}

# ALB/NLB Module
module "alb" {
  source = "./modules/alb"
  count  = var.enable_alb && var.enable_networking ? 1 : 0

  project_name          = var.project_name
  vpc_id                = module.networking[0].vpc_id
  public_subnet_ids     = module.networking[0].public_subnet_ids
  private_subnet_ids    = module.networking[0].private_subnet_ids
  security_group_id     = module.networking[0].security_group_web_id
  ec2_instance_id       = var.enable_compute ? module.compute[0].ec2_instance_id : ""
  enable_ec2_attachment = false # EC2 ID is computed, attach manually after apply
  common_tags           = local.common_tags

  depends_on = [module.networking, module.compute]
}

# AppSync Module
module "appsync" {
  source = "./modules/appsync"
  count  = var.enable_appsync && var.enable_security ? 1 : 0

  project_name     = var.project_name
  appsync_role_arn = module.security[0].appsync_role_arn
  common_tags      = local.common_tags

  depends_on = [module.security]
}

# Batch Module
module "batch" {
  source = "./modules/batch"
  count  = var.enable_batch && var.enable_networking && var.enable_security ? 1 : 0

  project_name             = var.project_name
  aws_region               = var.aws_region
  subnet_ids               = module.networking[0].private_subnet_ids
  security_group_id        = module.networking[0].security_group_web_id
  batch_service_role_arn   = module.security[0].batch_service_role_arn
  batch_execution_role_arn = module.security[0].batch_execution_role_arn
  common_tags              = local.common_tags

  depends_on = [module.networking, module.security]
}

# Budgets Module (Global)
module "budgets" {
  source = "./modules/budgets"
  count  = var.enable_budgets ? 1 : 0

  project_name = var.project_name
  budget_limit = tostring(var.cost_limit)
  alert_email  = var.budget_alert_email
  common_tags  = local.common_tags

  providers = {
    aws = aws.us_east_1
  }
}

# CloudFormation Module
module "cloudformation" {
  source = "./modules/cloudformation"
  count  = var.enable_cloudformation ? 1 : 0

  project_name = var.project_name
  account_id   = data.aws_caller_identity.current.account_id
  common_tags  = local.common_tags
}

# ElastiCache Module
module "elasticache" {
  source = "./modules/elasticache"
  count  = var.enable_elasticache && var.enable_networking ? 1 : 0

  project_name      = var.project_name
  subnet_ids        = module.networking[0].private_subnet_ids
  security_group_id = module.networking[0].security_group_database_id
  common_tags       = local.common_tags

  depends_on = [module.networking]
}

# Security Hub Module
module "securityhub" {
  source = "./modules/securityhub"
  count  = var.enable_securityhub ? 1 : 0

  project_name = var.project_name
  aws_region   = var.aws_region
  common_tags  = local.common_tags
}

# Service Catalog Module
module "servicecatalog" {
  source = "./modules/servicecatalog"
  count  = var.enable_servicecatalog ? 1 : 0

  project_name = var.project_name
  common_tags  = local.common_tags
}

# SWF Module
module "swf" {
  source = "./modules/swf"
  count  = var.enable_swf ? 1 : 0

  project_name = var.project_name
  common_tags  = local.common_tags
}

# VPC Peering Module
module "vpc_peering" {
  source = "./modules/vpc_peering"
  count  = var.enable_vpc_peering && var.enable_networking ? 1 : 0

  project_name = var.project_name
  vpc_id       = module.networking[0].vpc_id
  common_tags  = local.common_tags

  depends_on = [module.networking]
}

# MQ Module
module "mq" {
  source = "./modules/mq"
  count  = var.enable_mq && var.enable_networking ? 1 : 0

  project_name      = var.project_name
  subnet_id         = module.networking[0].private_subnet_ids[0]
  security_group_id = module.networking[0].security_group_database_id
  common_tags       = local.common_tags

  depends_on = [module.networking]
}
