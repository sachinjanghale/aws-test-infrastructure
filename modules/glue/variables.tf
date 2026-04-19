variable "project_name" { type = string }
variable "glue_role_arn" { type = string }
variable "s3_bucket_name" { type = string }
variable "common_tags" {
  type    = map(string)
  default = {}
}
