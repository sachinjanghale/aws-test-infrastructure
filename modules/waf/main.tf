# WAFv2 Regional Module

resource "aws_wafv2_ip_set" "main" {
  name               = "${var.project_name}-ip-set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["10.0.0.0/8", "192.168.0.0/16"]

  tags = merge(var.common_tags, { Name = "${var.project_name}-waf-ip-set" })
}

resource "aws_wafv2_regex_pattern_set" "main" {
  name  = "${var.project_name}-regex-set"
  scope = "REGIONAL"

  regular_expression {
    regex_string = "^/api/.*"
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-waf-regex-set" })
}

resource "aws_wafv2_rule_group" "main" {
  name     = "${var.project_name}-rule-group"
  scope    = "REGIONAL"
  capacity = 10

  rule {
    name     = "block-bad-ips"
    priority = 1

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.main.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-block-bad-ips"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-rule-group"
    sampled_requests_enabled   = true
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-waf-rule-group" })
}

resource "aws_wafv2_web_acl" "regional" {
  name  = "${var.project_name}-web-acl"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "rate-limit"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-web-acl"
    sampled_requests_enabled   = true
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-waf-web-acl" })
}

resource "aws_wafv2_web_acl_logging_configuration" "main" {
  log_destination_configs = [var.cloudwatch_log_group_arn]
  resource_arn            = aws_wafv2_web_acl.regional.arn
}
