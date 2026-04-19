# X-Ray Module

resource "aws_xray_sampling_rule" "main" {
  rule_name      = "${var.project_name}-sampling-rule"
  priority       = 9999
  version        = 1
  reservoir_size = 1
  fixed_rate     = 0.05
  url_path       = "*"
  host           = "*"
  http_method    = "*"
  service_type   = "*"
  service_name   = "*"
  resource_arn   = "*"

  attributes = {
    Project = var.project_name
  }
}
