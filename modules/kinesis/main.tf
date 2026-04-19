# Kinesis Module - Streams and Firehose

resource "aws_kinesis_stream" "main" {
  name             = "${var.project_name}-stream"
  shard_count      = 1
  retention_period = 24

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-kinesis-stream" })
}

resource "aws_kinesis_firehose_delivery_stream" "main" {
  name        = "${var.project_name}-firehose"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = var.firehose_role_arn
    bucket_arn = var.s3_bucket_arn
    prefix     = "firehose/"

    buffering_size     = 5
    buffering_interval = 300

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "/aws/kinesisfirehose/${var.project_name}"
      log_stream_name = "S3Delivery"
    }
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-firehose" })
}
