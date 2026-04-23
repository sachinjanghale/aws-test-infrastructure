variable "project_name" {
  type = string
}

variable "ses_email" {
  type    = string
  default = "test@example.com"
}

variable "domain_name" {
  type    = string
  default = ""
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
