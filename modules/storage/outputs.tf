output "s3_bucket_names" {
  description = "List of S3 bucket names"
  value = [
    aws_s3_bucket.versioned.id,
    aws_s3_bucket.encrypted.id
  ]
}

output "s3_bucket_arns" {
  description = "List of S3 bucket ARNs"
  value = [
    aws_s3_bucket.versioned.arn,
    aws_s3_bucket.encrypted.arn
  ]
}

output "s3_versioned_bucket_name" {
  description = "Versioned S3 bucket name"
  value       = aws_s3_bucket.versioned.id
}

output "s3_versioned_bucket_arn" {
  description = "Versioned S3 bucket ARN"
  value       = aws_s3_bucket.versioned.arn
}

output "s3_encrypted_bucket_name" {
  description = "Encrypted S3 bucket name"
  value       = aws_s3_bucket.encrypted.id
}

output "s3_encrypted_bucket_arn" {
  description = "Encrypted S3 bucket ARN"
  value       = aws_s3_bucket.encrypted.arn
}

output "ebs_volume_id" {
  description = "EBS volume ID"
  value       = aws_ebs_volume.data.id
}

output "ebs_volume_arn" {
  description = "EBS volume ARN"
  value       = aws_ebs_volume.data.arn
}

output "estimated_cost" {
  description = "Estimated monthly cost for storage resources"
  value       = 0.704 # 8GB EBS gp3 * $0.088/GB-month
}
