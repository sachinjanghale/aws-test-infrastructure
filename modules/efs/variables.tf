variable "project_name" { type = string }
variable "kms_key_arn" {
  type    = string
  default = ""
}
variable "subnet_ids" { type = list(string) }
variable "security_group_id" { type = string }
variable "common_tags" {
  type    = map(string)
  default = {}
}
