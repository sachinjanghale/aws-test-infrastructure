variable "project_name" { type = string }
variable "aws_region" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_group_id" { type = string }
variable "batch_service_role_arn" { type = string }
variable "batch_execution_role_arn" { type = string }
variable "common_tags" {
  type    = map(string)
  default = {}
}
