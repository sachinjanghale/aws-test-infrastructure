variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for ECS placement"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ECS tasks"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "IAM role ARN for ECS task execution"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "IAM role ARN for ECS tasks"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "kms_key_arn" {
  description = "KMS key ARN for ECR encryption"
  type        = string
  default     = ""
}

variable "db_secret_arn" {
  description = "Secrets Manager ARN for DB credentials injected into ECS containers"
  type        = string
  default     = ""
}

variable "api_keys_secret_arn" {
  description = "Secrets Manager ARN for API keys injected into ECS containers"
  type        = string
  default     = ""
}
