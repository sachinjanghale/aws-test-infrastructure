variable "project_name" { type = string }
variable "subnet_id" { type = string }
variable "security_group_id" { type = string }
variable "mq_password" {
  type      = string
  sensitive = true
  default   = "MqPassword123!"
}
variable "common_tags" {
  type    = map(string)
  default = {}
}
