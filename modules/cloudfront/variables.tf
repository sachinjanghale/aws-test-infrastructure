variable "project_name" { type = string }
variable "s3_bucket_domain" { type = string }
variable "common_tags" {
  type    = map(string)
  default = {}
}
