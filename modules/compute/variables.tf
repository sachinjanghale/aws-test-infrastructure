variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for EC2 placement"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for EC2"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for EC2"
  type        = string
}

variable "lambda_execution_role_arn" {
  description = "IAM role ARN for Lambda execution"
  type        = string
}

variable "ec2_instance_profile_name" {
  description = "IAM instance profile name for EC2"
  type        = string
}

variable "ebs_volume_id" {
  description = "EBS volume ID to attach to EC2"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "sqs_queue_arn" {
  description = "SQS queue ARN for Lambda event source mapping"
  type        = string
  default     = null
}

variable "sqs_dlq_arn" {
  description = "SQS DLQ ARN for Lambda failure destination"
  type        = string
  default     = null
}

variable "enable_messaging" {
  description = "Whether messaging module is enabled"
  type        = bool
  default     = false
}

variable "db_secret_arn" {
  description = "Secrets Manager ARN for DB credentials"
  type        = string
  default     = ""
}

variable "api_keys_secret_arn" {
  description = "Secrets Manager ARN for API keys"
  type        = string
  default     = ""
}

variable "rds_endpoint" {
  description = "RDS endpoint for Lambda environment"
  type        = string
  default     = ""
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for Lambda environment"
  type        = string
  default     = ""
}

variable "s3_bucket_name" {
  description = "S3 bucket name for Lambda environment"
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for VPC-attached Lambda"
  type        = list(string)
  default     = []
}

variable "lambda_security_group_id" {
  description = "Security group ID for VPC-attached Lambda"
  type        = string
  default     = ""
}

variable "enable_s3_trigger" {
  description = "Enable S3 EventBridge trigger for Lambda"
  type        = bool
  default     = false
}
