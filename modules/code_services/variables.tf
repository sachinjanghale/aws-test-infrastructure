variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "enable_codepipeline" {
  description = "Enable CodePipeline"
  type        = bool
  default     = false
}

variable "s3_artifact_bucket_name" {
  description = "S3 bucket name for build artifacts"
  type        = string
}

variable "codebuild_role_arn" {
  description = "IAM role ARN for CodeBuild"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
