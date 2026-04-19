variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "enable_rds" {
  description = "Enable RDS instance"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID for RDS placement"
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for RDS"
  type        = list(string)
  default     = []
}

variable "security_group_id" {
  description = "Security group ID for RDS"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
  default     = ""
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  default     = "ChangeMe123!"
  sensitive   = true
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "rds_monitoring_role_arn" {
  description = "Dedicated IAM role ARN for RDS enhanced monitoring"
  type        = string
  default     = ""
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for RDS event notifications"
  type        = string
  default     = ""
}

variable "rds_secret_arn" {
  description = "Secrets Manager ARN for RDS master credentials"
  type        = string
  default     = ""
}

variable "enable_sns_subscription" {
  description = "Enable RDS event subscription to SNS (set to true only when SNS topic exists)"
  type        = bool
  default     = false
}
