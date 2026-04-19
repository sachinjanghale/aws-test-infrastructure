variable "project_name" { type = string }
variable "cloudwatch_log_group_arn" { type = string }
variable "common_tags" {
  type    = map(string)
  default = {}
}
