output "sns_topic_arns" {
  description = "List of SNS topic ARNs"
  value = [
    aws_sns_topic.standard.arn,
    aws_sns_topic.fifo.arn
  ]
}

output "sns_standard_topic_arn" {
  description = "Standard SNS topic ARN"
  value       = aws_sns_topic.standard.arn
}

output "sns_standard_topic_name" {
  description = "Standard SNS topic name"
  value       = aws_sns_topic.standard.name
}

output "sns_fifo_topic_arn" {
  description = "FIFO SNS topic ARN"
  value       = aws_sns_topic.fifo.arn
}

output "sns_fifo_topic_name" {
  description = "FIFO SNS topic name"
  value       = aws_sns_topic.fifo.name
}

output "sqs_queue_urls" {
  description = "List of SQS queue URLs"
  value = [
    aws_sqs_queue.standard.url,
    aws_sqs_queue.fifo.url
  ]
}

output "sqs_queue_arns" {
  description = "List of SQS queue ARNs"
  value = [
    aws_sqs_queue.standard.arn,
    aws_sqs_queue.fifo.arn
  ]
}

output "sqs_standard_queue_url" {
  description = "Standard SQS queue URL"
  value       = aws_sqs_queue.standard.url
}

output "sqs_standard_queue_arn" {
  description = "Standard SQS queue ARN"
  value       = aws_sqs_queue.standard.arn
}

output "sqs_fifo_queue_url" {
  description = "FIFO SQS queue URL"
  value       = aws_sqs_queue.fifo.url
}

output "sqs_fifo_queue_arn" {
  description = "FIFO SQS queue ARN"
  value       = aws_sqs_queue.fifo.arn
}

output "sqs_dlq_url" {
  description = "Dead letter queue URL"
  value       = aws_sqs_queue.standard_dlq.url
}

output "sqs_dlq_arn" {
  description = "Dead letter queue ARN"
  value       = aws_sqs_queue.standard_dlq.arn
}

output "estimated_cost" {
  description = "Estimated monthly cost for messaging resources"
  value       = 0 # SNS and SQS are free tier
}
