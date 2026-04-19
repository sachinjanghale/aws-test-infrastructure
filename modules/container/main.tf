# Container Module - ECR Repository and ECS Cluster/Service

# ECR Repository
resource "aws_ecr_repository" "main" {
  name                 = "${var.project_name}-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-app"
      Purpose = "ECR repository for container images"
    }
  )
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Expire untagged images older than 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-cluster"
      Purpose = "ECS cluster for containerized applications"
    }
  )
}

# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7

  tags = merge(
    var.common_tags,
    {
      Name    = "/ecs/${var.project_name}"
      Purpose = "Log group for ECS tasks"
    }
  )
}

# ECS Task Definition - wired to Secrets Manager
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-container"
      image     = "nginx:alpine"
      essential = true

      portMappings = [
        { containerPort = 80, protocol = "tcp" }
      ]

      # Plain environment variables
      environment = [
        { name = "PROJECT_NAME", value = var.project_name },
        { name = "ENVIRONMENT", value = "test" },
        { name = "DB_SECRET_ARN", value = var.db_secret_arn },
        { name = "API_KEYS_SECRET_ARN", value = var.api_keys_secret_arn }
      ]

      # Secrets from Secrets Manager - injected as env vars at runtime
      secrets = var.db_secret_arn != "" ? [
        {
          name      = "DB_USERNAME"
          valueFrom = "${var.db_secret_arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${var.db_secret_arn}:password::"
        },
        {
          name      = "DB_HOST"
          valueFrom = "${var.db_secret_arn}:host::"
        }
      ] : []

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = merge(var.common_tags, {
    Name    = "${var.project_name}-task"
    Purpose = "ECS task definition with Secrets Manager integration"
  })
}

# ECS Service
resource "aws_ecs_service" "main" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-service"
      Purpose = "ECS service for running containers"
    }
  )
}

# Data source for current region
data "aws_region" "current" {}

# ECR Repository Policy
resource "aws_ecr_repository_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPushPull"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}

# Data source for current account
data "aws_caller_identity" "current" {}

# ECR Repository - Immutable tags (edge case)
resource "aws_ecr_repository" "immutable" {
  name                 = "${var.project_name}-immutable"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn != "" ? var.kms_key_arn : null
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-immutable"
      Purpose = "ECR repo with immutable tags and KMS encryption"
    }
  )
}

# ECR Lifecycle Policy for immutable repo
resource "aws_ecr_lifecycle_policy" "immutable" {
  repository = aws_ecr_repository.immutable.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = { type = "expire" }
      }
    ]
  })
}

# ECR Repository Policy for immutable repo (cross-account access edge case)
resource "aws_ecr_repository_policy" "immutable" {
  repository = aws_ecr_repository.immutable.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPull"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}

# ECR Repository - No scanning (edge case: scanning disabled)
resource "aws_ecr_repository" "no_scan" {
  name                 = "${var.project_name}-no-scan"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-no-scan"
      Purpose = "ECR repo with scanning disabled"
    }
  )
}
