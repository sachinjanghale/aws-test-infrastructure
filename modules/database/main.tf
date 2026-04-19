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

  tags = merge(var.common_tags, {
    Name    = "${var.project_name}-simple-table"
    Purpose = "DynamoDB table with simple hash key"
    Schema  = "hash-only"
  })
}

# DynamoDB Table 2 - Composite key (hash + range) with GSI
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

  tags = merge(var.common_tags, {
    Name    = "${var.project_name}-composite-table"
    Purpose = "DynamoDB table with composite key and GSI"
    Schema  = "hash-range"
  })
}

# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  count       = var.enable_rds ? 1 : 0
  name        = "${var.project_name}-db-subnet-group"
  subnet_ids  = var.private_subnet_ids
  description = "Subnet group for ${var.project_name} RDS instance"

  tags = merge(var.common_tags, {
    Name    = "${var.project_name}-db-subnet-group"
    Purpose = "RDS subnet group"
  })
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

  tags = merge(var.common_tags, { Name = "${var.project_name}-mysql-params" })
}

# RDS Option Group (edge case: custom options)
resource "aws_db_option_group" "main" {
  count                    = var.enable_rds ? 1 : 0
  name                     = "${var.project_name}-mysql-options"
  option_group_description = "Option group for ${var.project_name} MySQL"
  engine_name              = "mysql"
  major_engine_version     = "8.0"

  tags = merge(var.common_tags, { Name = "${var.project_name}-mysql-options" })
}

# RDS Instance - wired to Secrets Manager for credentials
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
  option_group_name      = aws_db_option_group.main[0].name

  # Enhanced monitoring with dedicated role
  monitoring_interval = 60
  monitoring_role_arn = var.rds_monitoring_role_arn != "" ? var.rds_monitoring_role_arn : null

  backup_retention_period         = 7
  backup_window                   = "03:00-04:00"
  maintenance_window              = "mon:04:00-mon:05:00"
  skip_final_snapshot             = true
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
  auto_minor_version_upgrade      = true
  deletion_protection             = false

  tags = merge(var.common_tags, {
    Name           = "${var.project_name}-mysql"
    Purpose        = "MySQL RDS instance for testing"
    Engine         = "mysql-8.0"
    SecretsManager = var.rds_secret_arn != "" ? var.rds_secret_arn : "not-configured"
  })
}

# RDS Snapshot (edge case: manual snapshot)
resource "aws_db_snapshot" "main" {
  count                  = var.enable_rds ? 1 : 0
  db_instance_identifier = aws_db_instance.main[0].identifier
  db_snapshot_identifier = "${var.project_name}-mysql-snapshot"

  tags = merge(var.common_tags, { Name = "${var.project_name}-mysql-snapshot" })

  depends_on = [aws_db_instance.main]
}

# RDS Event Subscription - wired to SNS topic
resource "aws_db_event_subscription" "main" {
  count     = var.enable_rds && var.enable_sns_subscription ? 1 : 0
  name      = "${var.project_name}-rds-events"
  sns_topic = var.sns_topic_arn

  source_type = "db-instance"
  source_ids  = [aws_db_instance.main[0].identifier]

  event_categories = [
    "availability", "deletion", "failover",
    "failure", "maintenance", "notification", "recovery",
  ]

  tags = merge(var.common_tags, { Name = "${var.project_name}-rds-events" })
}
