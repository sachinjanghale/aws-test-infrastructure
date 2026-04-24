# SWF Module - Simple Workflow

resource "random_id" "swf_suffix" {
  byte_length = 4
}

resource "aws_swf_domain" "main" {
  name                                        = "${var.project_name}-swf-${random_id.swf_suffix.hex}"
  description                                 = "SWF domain for ${var.project_name}"
  workflow_execution_retention_period_in_days = 1

  tags = merge(var.common_tags, { Name = "${var.project_name}-swf" })
}
