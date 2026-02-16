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
  default     = ""
}

variable "sqs_dlq_arn" {
  description = "SQS DLQ ARN for Lambda failure destination"
  type        = string
  default     = ""
}
