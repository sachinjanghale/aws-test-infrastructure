variable "project_name" { type = string }
variable "kms_key_id" {
  type    = string
  default = ""
}
variable "common_tags" {
  type    = map(string)
  default = {}
}
