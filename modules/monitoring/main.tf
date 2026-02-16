# Monitoring Module - CloudWatch Logs, Metrics, Alarms, Dashboard, CloudTrail

# CloudWatch Log Groups for Lambda Functions
resource "aws_cloudwatch_log_group" "lambda" {
  count             = length(var.lambda_function_names)
  name              = "/aws/lambda/${var.lambda_function_names[count.index]}"
  retention_in_days = 7

  tags = merge(
    var.common_tags,
    {
      Name    = "/aws/lambda/${var.lambda_function_names[count.index]}"
      Purpose = "Log group for Lambda function"
    }
  )
}

# CloudWatch Log Group for EC2
resource "aws_cloudwatch_log_group" "ec2" {
  name              = "/aws/ec2/${var.project_name}"
  retention_in_days = 7

  tags = merge(
    var.common_tags,
    {
      Name    = "/aws/ec2/${var.project_name}"
      Purpose = "Log group for EC2 instances"
    }
  )
}

# CloudWatch Metric Alarm for EC2 CPU
resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  count               = length(var.ec2_instance_ids)
  alarm_name          = "${var.project_name}-ec2-high-cpu-${count.index}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors EC2 CPU utilization"
  alarm_actions       = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []

  dimensions = {
    InstanceId = var.ec2_instance_ids[count.index]
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-ec2-high-cpu-${count.index}"
      Purpose = "EC2 CPU utilization alarm"
    }
  )
}

# CloudWatch Metric Alarm for Lambda Errors
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  count               = length(var.lambda_function_names)
  alarm_name          = "${var.project_name}-lambda-errors-${count.index}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "This metric monitors Lambda function errors"
  alarm_actions       = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = var.lambda_function_names[count.index]
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-lambda-errors-${count.index}"
      Purpose = "Lambda error alarm"
    }
  )
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            for instance_id in var.ec2_instance_ids : [
              "AWS/EC2",
              "CPUUtilization",
              { "InstanceId" = instance_id }
            ]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "EC2 CPU Utilization"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            for function_name in var.lambda_function_names : [
              "AWS/Lambda",
              "Invocations",
              { "FunctionName" = function_name }
            ]
          ]
          period = 300
          stat   = "Sum"
          region = data.aws_region.current.name
          title  = "Lambda Invocations"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            for function_name in var.lambda_function_names : [
              "AWS/Lambda",
              "Errors",
              { "FunctionName" = function_name }
            ]
          ]
          period = 300
          stat   = "Sum"
          region = data.aws_region.current.name
          title  = "Lambda Errors"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            for function_name in var.lambda_function_names : [
              "AWS/Lambda",
              "Duration",
              { "FunctionName" = function_name }
            ]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "Lambda Duration"
        }
      }
    ]
  })
}

# Data source for current region
data "aws_region" "current" {}

# Data source for current account
data "aws_caller_identity" "current" {}

# S3 Bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "${var.project_name}-cloudtrail-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-cloudtrail-logs"
      Purpose = "S3 bucket for CloudTrail logs"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Policy for CloudTrail
resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# CloudTrail
resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }

    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda"]
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-trail"
      Purpose = "CloudTrail for API logging"
    }
  )

  depends_on = [aws_s3_bucket_policy.cloudtrail]
}
