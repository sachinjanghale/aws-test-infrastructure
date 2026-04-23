variable "project_name" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "security_group_id" { type = string }
variable "ec2_instance_id" {
  type    = string
  default = ""
}

variable "enable_ec2_attachment" {
  description = "Enable target group attachment to EC2 (use false when EC2 ID is computed)"
  type        = bool
  default     = false
}
variable "common_tags" {
  type    = map(string)
  default = {}
}
