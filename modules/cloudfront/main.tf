# CloudFront Module (Global service)

resource "aws_cloudfront_cache_policy" "main" {
  name        = "${var.project_name}-cache-policy"
  comment     = "Cache policy for ${var.project_name}"
  default_ttl = 86400
  max_ttl     = 31536000
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.project_name} CloudFront distribution"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  origin {
    domain_name = var.s3_bucket_domain
    origin_id   = "${var.project_name}-s3-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${var.project_name}-s3-origin"
    cache_policy_id        = aws_cloudfront_cache_policy.main.id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-cloudfront" })
}

resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "OAI for ${var.project_name}"
}
