variable "project_name" { type = string }
variable "ec2_instance_id" {
  type    = string
  default = ""
}

variable "enable_ec2_eip" {
  description = "Enable EIP attachment to EC2 (use false when EC2 ID is computed)"
  type        = bool
  default     = false
}
variable "subnet_id" { type = string }
variable "security_group_id" { type = string }
variable "common_tags" {
  type    = map(string)
  default = {}
}
