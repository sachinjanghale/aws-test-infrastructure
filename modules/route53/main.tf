# Route53 Module - Hosted Zone and DNS Records

# Hosted Zone for domain
resource "aws_route53_zone" "main" {
  name    = var.domain_name
  comment = "Managed by Terraform for ${var.project_name}"

  tags = merge(
    var.common_tags,
    {
      Name    = var.domain_name
      Purpose = "DNS hosted zone for test infrastructure"
    }
  )
}

# TXT record for domain verification
resource "aws_route53_record" "verification" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "TXT"
  ttl     = 300
  records = ["v=spf1 include:amazonses.com ~all"]
}

# Data source for current region
data "aws_region" "current" {}
