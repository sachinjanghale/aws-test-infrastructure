# Security Module - IAM Roles, Policies, KMS, Secrets Manager

# KMS Key for encryption
resource "aws_kms_key" "main" {
  description             = "KMS key for ${var.project_name} encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name    = "${var.project_name}-kms-key"
    Project = var.project_name
  }
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project_name}-key"
  target_key_id = aws_kms_key.main.key_id
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_execution" {
  name = "${var.project_name}-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-lambda-execution-role"
      Purpose = "Execution role for Lambda functions"
    }
  )
}

# IAM Policy for Lambda
resource "aws_iam_role_policy" "lambda_execution" {
  name = "${var.project_name}-lambda-execution-policy"
  role = aws_iam_role.lambda_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/${var.project_name}-*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::${var.project_name}-*/*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:${var.project_name}-*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ]
        Resource = aws_kms_key.main.arn
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:SendMessage"
        ]
        Resource = "arn:aws:sqs:*:*:${var.project_name}-*"
      }
    ]
  })
}

# Attach AWS managed policy for Lambda VPC execution
resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_instance" {
  name = "${var.project_name}-ec2-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-ec2-instance-role"
      Purpose = "Instance role for EC2 instances"
    }
  )
}

# IAM Policy for EC2
resource "aws_iam_role_policy" "ec2_instance" {
  name = "${var.project_name}-ec2-instance-policy"
  role = aws_iam_role.ec2_instance.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-*",
          "arn:aws:s3:::${var.project_name}-*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:${var.project_name}-*"
      }
    ]
  })
}

# Attach AWS managed policy for SSM (for Session Manager access)
resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Additional IAM Policy for EC2 - Full S3 access to encrypted bucket (edge case)
resource "aws_iam_role_policy" "ec2_s3_full_access" {
  name = "${var.project_name}-ec2-s3-full-access-policy"
  role = aws_iam_role.ec2_instance.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-encrypted-*",
          "arn:aws:s3:::${var.project_name}-encrypted-*/*"
        ]
      }
    ]
  })
}

# IAM Instance Profile for EC2
resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-ec2-instance-profile"
  role = aws_iam_role.ec2_instance.name

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-ec2-instance-profile"
      Purpose = "Instance profile for EC2 instances"
    }
  )
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-ecs-task-execution-role"
      Purpose = "Execution role for ECS tasks"
    }
  )
}

# Attach AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM Policy for ECS Task Execution (additional permissions)
resource "aws_iam_role_policy" "ecs_task_execution" {
  name = "${var.project_name}-ecs-task-execution-policy"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:${var.project_name}-*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = aws_kms_key.main.arn
      }
    ]
  })
}

# IAM Role for ECS Task (application role)
resource "aws_iam_role" "ecs_task" {
  name = "${var.project_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-ecs-task-role"
      Purpose = "Task role for ECS containers"
    }
  )
}

# IAM Policy for ECS Task
resource "aws_iam_role_policy" "ecs_task" {
  name = "${var.project_name}-ecs-task-policy"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::${var.project_name}-*/*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/${var.project_name}-*"
      }
    ]
  })
}

# IAM Role for Step Functions
resource "aws_iam_role" "step_functions" {
  name = "${var.project_name}-step-functions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-step-functions-role"
      Purpose = "Execution role for Step Functions"
    }
  )
}

# IAM Policy for Step Functions
resource "aws_iam_role_policy" "step_functions" {
  name = "${var.project_name}-step-functions-policy"
  role = aws_iam_role.step_functions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = "arn:aws:lambda:*:*:function:${var.project_name}-*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Role for CodeBuild
resource "aws_iam_role" "codebuild" {
  name = "${var.project_name}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-codebuild-role"
      Purpose = "Service role for CodeBuild"
    }
  )
}

# IAM Policy for CodeBuild
resource "aws_iam_role_policy" "codebuild" {
  name = "${var.project_name}-codebuild-policy"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::${var.project_name}-*/*"
      },
      {
        Effect = "Allow"
        Action = [
          "codecommit:GitPull"
        ]
        Resource = "arn:aws:codecommit:*:*:${var.project_name}-*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      }
    ]
  })
}

# Random suffix for Secrets Manager to avoid conflicts with deleted secrets
resource "random_id" "secret_suffix" {
  byte_length = 4
}

# Secrets Manager Secrets
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.project_name}-db-credentials-${random_id.secret_suffix.hex}"
  description             = "Database credentials for ${var.project_name}"
  kms_key_id              = aws_kms_key.main.id
  recovery_window_in_days = 7

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-db-credentials"
      Purpose = "Database credentials storage"
    }
  )
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "admin"
    password = "ChangeMe123!"
    engine   = "mysql"
    host     = "localhost"
    port     = 3306
    dbname   = "testdb"
  })
}

resource "aws_secretsmanager_secret" "api_keys" {
  name                    = "${var.project_name}-api-keys-${random_id.secret_suffix.hex}"
  description             = "API keys for ${var.project_name}"
  kms_key_id              = aws_kms_key.main.id
  recovery_window_in_days = 7

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-api-keys"
      Purpose = "API keys and tokens storage"
    }
  )
}

resource "aws_secretsmanager_secret_version" "api_keys" {
  secret_id = aws_secretsmanager_secret.api_keys.id
  secret_string = jsonencode({
    api_key       = "sample-api-key-12345"
    api_secret    = "sample-api-secret-67890"
    webhook_token = "sample-webhook-token"
  })
}

# IAM Group for developers
resource "aws_iam_group" "developers" {
  name = "${var.project_name}-developers"
  path = "/"
}

# IAM Group Policy
resource "aws_iam_group_policy" "developer_policy" {
  name  = "${var.project_name}-developer-policy"
  group = aws_iam_group.developers.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach AWS managed policy to group
resource "aws_iam_group_policy_attachment" "developer_readonly" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# IAM User 1
resource "aws_iam_user" "test_user1" {
  name = "${var.project_name}-test-user1"
  path = "/"

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-test-user1"
      Purpose = "Test IAM user for migration testing"
    }
  )
}

# IAM User 2
resource "aws_iam_user" "test_user2" {
  name = "${var.project_name}-test-user2"
  path = "/"

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-test-user2"
      Purpose = "Test IAM user for migration testing"
    }
  )
}

# IAM User Group Membership
resource "aws_iam_user_group_membership" "test_user1" {
  user = aws_iam_user.test_user1.name
  groups = [
    aws_iam_group.developers.name
  ]
}

resource "aws_iam_user_group_membership" "test_user2" {
  user = aws_iam_user.test_user2.name
  groups = [
    aws_iam_group.developers.name
  ]
}

# IAM User Policy (inline)
resource "aws_iam_user_policy" "test_user1_policy" {
  name = "${var.project_name}-user1-policy"
  user = aws_iam_user.test_user1.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query"
        ]
        Resource = "*"
      }
    ]
  })
}

# Standalone IAM Policy
resource "aws_iam_policy" "custom_policy" {
  name        = "${var.project_name}-custom-policy"
  path        = "/"
  description = "Custom policy for testing"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-custom-policy"
      Purpose = "Custom IAM policy for testing"
    }
  )
}

# IAM User Policy Attachment
resource "aws_iam_user_policy_attachment" "test_user2_custom" {
  user       = aws_iam_user.test_user2.name
  policy_arn = aws_iam_policy.custom_policy.arn
}

# IAM Access Key for test_user1
resource "aws_iam_access_key" "test_user1" {
  user = aws_iam_user.test_user1.name
}
