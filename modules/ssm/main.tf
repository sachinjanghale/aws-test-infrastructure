# SSM Parameter Store Module

resource "aws_ssm_parameter" "string" {
  name        = "/${var.project_name}/config/app-name"
  type        = "String"
  value       = var.project_name
  description = "Application name parameter"

  tags = merge(var.common_tags, { Name = "${var.project_name}-ssm-string" })
}

resource "aws_ssm_parameter" "secure_string" {
  name        = "/${var.project_name}/config/db-password"
  type        = "SecureString"
  value       = "placeholder-password-123"
  description = "Database password (SecureString)"
  key_id      = var.kms_key_id != "" ? var.kms_key_id : null

  tags = merge(var.common_tags, { Name = "${var.project_name}-ssm-secure" })
}

resource "aws_ssm_parameter" "string_list" {
  name        = "/${var.project_name}/config/allowed-ips"
  type        = "StringList"
  value       = "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
  description = "Allowed IP ranges"

  tags = merge(var.common_tags, { Name = "${var.project_name}-ssm-list" })
}
