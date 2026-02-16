variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "lambda_function_arns" {
  description = "List of Lambda function ARNs to orchestrate"
  type        = list(string)
  default     = []
}

variable "step_function_role_arn" {
  description = "IAM role ARN for Step Functions"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
