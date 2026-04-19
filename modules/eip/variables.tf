variable "project_name" { type = string }
variable "ec2_instance_id" {
  type    = string
  default = ""
}
variable "subnet_id" { type = string }
variable "security_group_id" { type = string }
variable "common_tags" {
  type    = map(string)
  default = {}
}
