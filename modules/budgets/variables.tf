variable "project_name" {
  type = string
}

variable "budget_limit" {
  type    = string
  default = "100"
}

variable "alert_email" {
  type    = string
  default = "admin@example.com"
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
