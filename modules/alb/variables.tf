variable "project_name" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "security_group_id" { type = string }
variable "ec2_instance_id" {
  type    = string
  default = ""
}
variable "common_tags" {
  type    = map(string)
  default = {}
}
