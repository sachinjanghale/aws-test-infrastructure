variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "lambda_function_arns" {
  description = "Map of Lambda function ARNs"
  type        = map(string)
}

variable "lambda_function_names" {
  description = "Map of Lambda function names"
  type        = map(string)
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "api_gateway_role_arn" {
  description = "IAM role ARN for API Gateway to invoke Lambda"
  type        = string
  default     = ""
}

variable "enable_vpc_link" {
  description = "Enable VPC Link for private integrations"
  type        = bool
  default     = false
}

variable "nlb_arn" {
  description = "Network Load Balancer ARN for VPC Link"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "AWS region for API Gateway integrations"
  type        = string
}
