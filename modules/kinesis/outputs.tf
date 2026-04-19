output "stream_arn" { value = aws_kinesis_stream.main.arn }
output "firehose_arn" { value = aws_kinesis_firehose_delivery_stream.main.arn }
