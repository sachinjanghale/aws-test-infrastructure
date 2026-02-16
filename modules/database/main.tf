# Database Module - DynamoDB Tables and RDS

# DynamoDB Table 1 - Simple hash key
resource "aws_dynamodb_table" "simple" {
  name         = "${var.project_name}-simple-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn != "" ? var.kms_key_arn : null
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-simple-table"
      Purpose = "DynamoDB table with simple hash key"
      Schema  = "hash-only"
    }
  )
}

# DynamoDB Table 2 - Composite key (hash + range)
resource "aws_dynamodb_table" "composite" {
  name         = "${var.project_name}-composite-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  range_key    = "timestamp"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  attribute {
    name = "status"
    type = "S"
  }

  global_secondary_index {
    name            = "StatusIndex"
    hash_key        = "status"
    range_key       = "timestamp"
    projection_type = "ALL"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn != "" ? var.kms_key_arn : null
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-composite-table"
      Purpose = "DynamoDB table with composite key and GSI"
      Schema  = "hash-range"
    }
  )
}

# RDS Subnet Group (only if RDS is enabled)
resource "aws_db_subnet_group" "main" {
  count       = var.enable_rds ? 1 : 0
  name        = "${var.project_name}-db-subnet-group"
  subnet_ids  = var.private_subnet_ids
  description = "Subnet group for ${var.project_name} RDS instance"

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-db-subnet-group"
      Purpose = "RDS subnet group"
    }
  )
}

# RDS Parameter Group
resource "aws_db_parameter_group" "main" {
  count       = var.enable_rds ? 1 : 0
  name        = "${var.project_name}-mysql-params"
  family      = "mysql8.0"
  description = "Custom parameter group for ${var.project_name}"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-mysql-params"
      Purpose = "RDS parameter group"
    }
  )
}

# RDS Instance (db.t3.micro)
resource "aws_db_instance" "main" {
  count             = var.enable_rds ? 1 : 0
  identifier        = "${var.project_name}-mysql"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true
  kms_key_id        = var.kms_key_arn != "" ? var.kms_key_arn : null

  db_name  = "testdb"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main[0].name
  vpc_security_group_ids = [var.security_group_id]
  parameter_group_name   = aws_db_parameter_group.main[0].name

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  skip_final_snapshot       = true
  final_snapshot_identifier = "${var.project_name}-mysql-final-snapshot"

  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  auto_minor_version_upgrade = true
  deletion_protection        = false

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-mysql"
      Purpose = "MySQL RDS instance for testing"
      Engine  = "mysql-8.0"
    }
  )
}
