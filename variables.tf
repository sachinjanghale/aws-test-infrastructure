variable "aws_region" {
  description = "AWS region for resource provisioning"
  type        = string
  default     = "ap-south-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.aws_region))
    error_message = "AWS region must be a valid region identifier (e.g., ap-south-1, us-east-1)."
  }
}

variable "project_name" {
  description = "Project identifier for resource naming"
  type        = string
  default     = "infrasyn-test"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "cost_limit" {
  description = "Maximum estimated monthly cost in USD"
  type        = number
  default     = 100

  validation {
    condition     = var.cost_limit > 0
    error_message = "Cost limit must be greater than 0."
  }
}

# Module enable/disable flags
variable "enable_networking" {
  description = "Enable networking module (VPC, subnets, security groups)"
  type        = bool
  default     = true
}

variable "enable_security" {
  description = "Enable security module (IAM, KMS, Secrets Manager)"
  type        = bool
  default     = true
}

variable "enable_storage" {
  description = "Enable storage module (S3, EBS)"
  type        = bool
  default     = true
}

variable "enable_compute" {
  description = "Enable compute module (Lambda, EC2, Auto Scaling)"
  type        = bool
  default     = true
}

variable "enable_database" {
  description = "Enable database module (DynamoDB, RDS)"
  type        = bool
  default     = true
}

variable "enable_rds" {
  description = "Enable RDS instance (adds ~$15/month cost)"
  type        = bool
  default     = false
}

variable "enable_messaging" {
  description = "Enable messaging module (SNS, SQS)"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable monitoring module (CloudWatch, CloudTrail)"
  type        = bool
  default     = true
}

variable "enable_api" {
  description = "Enable API module (API Gateway)"
  type        = bool
  default     = true
}

variable "enable_container" {
  description = "Enable container module (ECR, ECS)"
  type        = bool
  default     = true
}

variable "enable_code_services" {
  description = "Enable code services module (CodeCommit, CodeBuild)"
  type        = bool
  default     = true
}

variable "enable_codepipeline" {
  description = "Enable CodePipeline (requires enable_code_services)"
  type        = bool
  default     = false
}

variable "enable_orchestration" {
  description = "Enable orchestration module (Step Functions, EventBridge)"
  type        = bool
  default     = true
}

# Networking configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones to use (defaults to first 2 AZs in region)"
  type        = list(string)
  default     = []
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets (adds cost)"
  type        = bool
  default     = false
}

# RDS configuration (only used if enable_rds is true)
variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  default     = ""
  sensitive   = true

  validation {
    condition     = var.db_password == "" || length(var.db_password) >= 8
    error_message = "Database password must be at least 8 characters long."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, test, prod)"
  type        = string
  default     = "test"

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod."
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_route53" {
  description = "Enable Route53 module (hosted zone and DNS records)"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Domain name for Route53 hosted zone"
  type        = string
  default     = ""
}

variable "enable_route53_health_checks" {
  description = "Enable Route53 health checks"
  type        = bool
  default     = false
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints for S3, DynamoDB, and Lambda"
  type        = bool
  default     = true
}

variable "enable_vpc_link" {
  description = "Enable API Gateway VPC Link (adds ~$18.25/month)"
  type        = bool
  default     = false
}
