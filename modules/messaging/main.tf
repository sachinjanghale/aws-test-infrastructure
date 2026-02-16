# Messaging Module - SNS Topics and SQS Queues

# SNS Topic 1 - Standard
resource "aws_sns_topic" "standard" {
  name              = "${var.project_name}-standard-topic"
  display_name      = "${var.project_name} Standard Topic"
  kms_master_key_id = var.kms_key_id != "" ? var.kms_key_id : null

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-standard-topic"
      Purpose = "Standard SNS topic for notifications"
      Type    = "standard"
    }
  )
}

# SNS Topic 2 - FIFO
resource "aws_sns_topic" "fifo" {
  name                        = "${var.project_name}-fifo-topic.fifo"
  display_name                = "${var.project_name} FIFO Topic"
  fifo_topic                  = true
  content_based_deduplication = true
  kms_master_key_id           = var.kms_key_id != "" ? var.kms_key_id : null

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-fifo-topic"
      Purpose = "FIFO SNS topic for ordered notifications"
      Type    = "fifo"
    }
  )
}

# SQS Queue 1 - Standard
resource "aws_sqs_queue" "standard" {
  name                              = "${var.project_name}-standard-queue"
  delay_seconds                     = 0
  max_message_size                  = 262144
  message_retention_seconds         = 345600 # 4 days
  receive_wait_time_seconds         = 10     # Long polling
  visibility_timeout_seconds        = 30
  kms_master_key_id                 = var.kms_key_id != "" ? var.kms_key_id : null
  kms_data_key_reuse_period_seconds = 300

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-standard-queue"
      Purpose = "Standard SQS queue for message processing"
      Type    = "standard"
    }
  )
}

# SQS Queue 2 - FIFO
resource "aws_sqs_queue" "fifo" {
  name                              = "${var.project_name}-fifo-queue.fifo"
  fifo_queue                        = true
  content_based_deduplication       = true
  delay_seconds                     = 0
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 10
  visibility_timeout_seconds        = 30
  kms_master_key_id                 = var.kms_key_id != "" ? var.kms_key_id : null
  kms_data_key_reuse_period_seconds = 300

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-fifo-queue"
      Purpose = "FIFO SQS queue for ordered message processing"
      Type    = "fifo"
    }
  )
}

# Dead Letter Queue for Standard Queue
resource "aws_sqs_queue" "standard_dlq" {
  name                              = "${var.project_name}-standard-dlq"
  message_retention_seconds         = 1209600 # 14 days
  kms_master_key_id                 = var.kms_key_id != "" ? var.kms_key_id : null
  kms_data_key_reuse_period_seconds = 300

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-standard-dlq"
      Purpose = "Dead letter queue for failed messages"
      Type    = "dlq"
    }
  )
}

# Redrive Policy for Standard Queue
resource "aws_sqs_queue_redrive_policy" "standard" {
  queue_url = aws_sqs_queue.standard.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.standard_dlq.arn
    maxReceiveCount     = 3
  })
}

# SQS Queue Policy for Standard Queue (allow SNS to send messages)
resource "aws_sqs_queue_policy" "standard" {
  queue_url = aws_sqs_queue.standard.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.standard.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.standard.arn
          }
        }
      }
    ]
  })
}

# SNS to SQS Subscription
resource "aws_sns_topic_subscription" "standard_to_sqs" {
  topic_arn            = aws_sns_topic.standard.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.standard.arn
  raw_message_delivery = false
}

# SNS to SQS Subscription for FIFO
resource "aws_sns_topic_subscription" "fifo_to_sqs" {
  topic_arn            = aws_sns_topic.fifo.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.fifo.arn
  raw_message_delivery = false
}

# SQS Queue Policy for FIFO Queue
resource "aws_sqs_queue_policy" "fifo" {
  queue_url = aws_sqs_queue.fifo.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.fifo.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.fifo.arn
          }
        }
      }
    ]
  })
}
