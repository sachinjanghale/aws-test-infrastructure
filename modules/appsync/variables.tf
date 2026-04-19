variable "project_name" { type = string }
variable "appsync_role_arn" { type = string }
variable "common_tags" {
  type    = map(string)
  default = {}
}
