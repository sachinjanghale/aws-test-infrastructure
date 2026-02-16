# AWS Test Infrastructure - Root Configuration
# This configuration orchestrates all modules for testing the infrasyn.app migration tool

# Data source to get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

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

  project_name = var.project_name
  common_tags  = local.common_tags
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
  sqs_queue_arn             = var.enable_messaging ? module.messaging[0].sqs_standard_queue_arn : ""
  sqs_dlq_arn               = var.enable_messaging ? module.messaging[0].sqs_dlq_arn : ""
  common_tags               = local.common_tags

  depends_on = [module.networking, module.security, module.storage, module.messaging]
}

# Database Module
module "database" {
  source = "./modules/database"
  count  = var.enable_database ? 1 : 0

  project_name       = var.project_name
  enable_rds         = var.enable_rds && var.enable_networking
  vpc_id             = var.enable_networking ? module.networking[0].vpc_id : ""
  private_subnet_ids = var.enable_networking ? module.networking[0].private_subnet_ids : []
  security_group_id  = var.enable_networking ? module.networking[0].security_group_database_id : ""
  kms_key_arn        = var.enable_security ? module.security[0].kms_key_arn : ""
  db_username        = var.db_username
  db_password        = var.db_password
  common_tags        = local.common_tags

  depends_on = [module.networking, module.security]
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
  common_tags                 = local.common_tags

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
