variable "project_name" { type = string }
variable "firehose_role_arn" { type = string }
variable "s3_bucket_arn" { type = string }
variable "common_tags" {
  type    = map(string)
  default = {}
}
