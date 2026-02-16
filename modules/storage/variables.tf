variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = ""
}

variable "availability_zone" {
  description = "Availability zone for EBS volume"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
