# Storage Module - S3 Buckets and EBS Volumes

# Random suffix for unique bucket names
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Bucket 1 - With versioning and lifecycle policies
resource "aws_s3_bucket" "versioned" {
  bucket        = "${var.project_name}-versioned-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-versioned-bucket"
      Purpose = "S3 bucket with versioning and lifecycle policies"
    }
  )
}

resource "aws_s3_bucket_versioning" "versioned" {
  bucket = aws_s3_bucket.versioned.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "versioned" {
  bucket = aws_s3_bucket.versioned.id

  rule {
    id     = "transition-old-versions"
    status = "Enabled"

    filter {
      prefix = ""
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 90
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
  }

  rule {
    id     = "expire-old-objects"
    status = "Enabled"

    expiration {
      days = 90
    }

    filter {
      prefix = "temp/"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "versioned" {
  bucket = aws_s3_bucket.versioned.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket 2 - With KMS encryption
resource "aws_s3_bucket" "encrypted" {
  bucket        = "${var.project_name}-encrypted-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-encrypted-bucket"
      Purpose = "S3 bucket with KMS encryption"
    }
  )
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encrypted" {
  bucket = aws_s3_bucket.encrypted.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_id != "" ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_id != "" ? var.kms_key_id : null
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "encrypted" {
  bucket = aws_s3_bucket.encrypted.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable logging on encrypted bucket (logs to versioned bucket)
resource "aws_s3_bucket_logging" "encrypted" {
  bucket = aws_s3_bucket.encrypted.id

  target_bucket = aws_s3_bucket.versioned.id
  target_prefix = "logs/"
}

# EBS Volume (gp3, 8GB)
resource "aws_ebs_volume" "data" {
  availability_zone = var.availability_zone
  size              = 8
  type              = "gp3"
  encrypted         = true
  kms_key_id        = var.kms_key_id != "" ? var.kms_key_id : null

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-data-volume"
      Purpose = "Additional EBS volume for EC2 instance"
    }
  )
}
