# SES Module - Email Identity, Configuration Set, Templates

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

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

# S3 bucket policy for SES to write emails
resource "aws_s3_bucket_policy" "ses" {
  bucket = var.s3_bucket_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSESPuts"
        Effect = "Allow"
        Principal = {
          Service = "ses.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::${var.s3_bucket_name}/ses/*"
        Condition = {
          StringEquals = {
            "aws:Referer" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
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

  depends_on = [aws_s3_bucket_policy.ses]
}
