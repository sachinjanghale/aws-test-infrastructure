# SES Module - Email Identity, Configuration Set, Templates

resource "aws_ses_email_identity" "main" {
  email = var.ses_email
}

resource "aws_ses_domain_identity" "main" {
  count  = var.domain_name != "" ? 1 : 0
  domain = var.domain_name
}

resource "aws_ses_configuration_set" "main" {
  name = "${var.project_name}-ses-config"

  delivery_options {
    tls_policy = "Require"
  }
}

resource "aws_ses_template" "main" {
  name    = "${var.project_name}-email-template"
  subject = "Hello from {{project_name}}"
  html    = "<h1>Hello {{name}}</h1><p>Welcome to {{project_name}}!</p>"
  text    = "Hello {{name}}, Welcome to {{project_name}}!"
}

resource "aws_ses_receipt_rule_set" "main" {
  rule_set_name = "${var.project_name}-rule-set"
}

resource "aws_ses_receipt_rule" "main" {
  name          = "${var.project_name}-receipt-rule"
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
  enabled       = true
  scan_enabled  = true

  s3_action {
    bucket_name = var.s3_bucket_name
    position    = 1
  }
}
