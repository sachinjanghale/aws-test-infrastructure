variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "rds_endpoint" {
  description = "RDS endpoint to store in secrets"
  type        = string
  default     = "not-yet-created"
}

variable "rds_identifier" {
  description = "RDS instance identifier"
  type        = string
  default     = ""
}

variable "elasticache_endpoint" {
  description = "ElastiCache endpoint to store in secrets"
  type        = string
  default     = "not-yet-created"
}
