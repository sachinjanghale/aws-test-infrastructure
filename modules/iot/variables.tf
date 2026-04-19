variable "project_name" { type = string }
variable "iot_role_arn" { type = string }
variable "lambda_function_arn" { type = string }
variable "common_tags" {
  type    = map(string)
  default = {}
}
