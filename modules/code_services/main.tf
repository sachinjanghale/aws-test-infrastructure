# Code Services Module - CodeCommit, CodeBuild, CodePipeline

# CodeCommit Repository
resource "aws_codecommit_repository" "main" {
  repository_name = "${var.project_name}-repo"
  description     = "Git repository for ${var.project_name}"

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-repo"
      Purpose = "Source code repository"
    }
  )
}

# CodeBuild Project
resource "aws_codebuild_project" "main" {
  name          = "${var.project_name}-build"
  description   = "Build project for ${var.project_name}"
  build_timeout = 60
  service_role  = var.codebuild_role_arn

  artifacts {
    type      = "S3"
    location  = var.s3_artifact_bucket_name
    packaging = "ZIP"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "PROJECT_NAME"
      value = var.project_name
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = "test"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/${var.project_name}"
      stream_name = "build-log"
    }
  }

  source {
    type            = "CODECOMMIT"
    location        = aws_codecommit_repository.main.clone_url_http
    git_clone_depth = 1
    buildspec       = <<-EOT
      version: 0.2
      phases:
        pre_build:
          commands:
            - echo "Pre-build phase"
            - echo "Project: $PROJECT_NAME"
        build:
          commands:
            - echo "Build phase"
            - echo "Building application..."
            - echo "Build completed on $(date)"
        post_build:
          commands:
            - echo "Post-build phase"
            - echo "Build successful!"
      artifacts:
        files:
          - '**/*'
    EOT
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-build"
      Purpose = "CodeBuild project for CI/CD"
    }
  )
}

# CloudWatch Log Group for CodeBuild
resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/aws/codebuild/${var.project_name}"
  retention_in_days = 7

  tags = merge(
    var.common_tags,
    {
      Name    = "/aws/codebuild/${var.project_name}"
      Purpose = "Log group for CodeBuild"
    }
  )
}

# IAM Role for CodePipeline (only if enabled)
resource "aws_iam_role" "codepipeline" {
  count = var.enable_codepipeline ? 1 : 0
  name  = "${var.project_name}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-codepipeline-role"
      Purpose = "Service role for CodePipeline"
    }
  )
}

# IAM Policy for CodePipeline
resource "aws_iam_role_policy" "codepipeline" {
  count = var.enable_codepipeline ? 1 : 0
  name  = "${var.project_name}-codepipeline-policy"
  role  = aws_iam_role.codepipeline[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion"
        ]
        Resource = "arn:aws:s3:::${var.s3_artifact_bucket_name}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:UploadArchive",
          "codecommit:GetUploadArchiveStatus"
        ]
        Resource = aws_codecommit_repository.main.arn
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = aws_codebuild_project.main.arn
      }
    ]
  })
}

# CodePipeline (optional)
resource "aws_codepipeline" "main" {
  count    = var.enable_codepipeline ? 1 : 0
  name     = "${var.project_name}-pipeline"
  role_arn = aws_iam_role.codepipeline[0].arn

  artifact_store {
    location = var.s3_artifact_bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName       = aws_codecommit_repository.main.repository_name
        BranchName           = "main"
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.main.name
      }
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-pipeline"
      Purpose = "CI/CD pipeline"
    }
  )
}

# EventBridge Rule for CodeCommit (trigger pipeline on push)
resource "aws_cloudwatch_event_rule" "codecommit" {
  count       = var.enable_codepipeline ? 1 : 0
  name        = "${var.project_name}-codecommit-trigger"
  description = "Trigger CodePipeline on CodeCommit push"

  event_pattern = jsonencode({
    source      = ["aws.codecommit"]
    detail-type = ["CodeCommit Repository State Change"]
    detail = {
      event         = ["referenceCreated", "referenceUpdated"]
      referenceType = ["branch"]
      referenceName = ["main"]
    }
    resources = [aws_codecommit_repository.main.arn]
  })

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-codecommit-trigger"
      Purpose = "EventBridge rule for CodeCommit"
    }
  )
}

# EventBridge Target for CodePipeline
resource "aws_cloudwatch_event_target" "codepipeline" {
  count     = var.enable_codepipeline ? 1 : 0
  rule      = aws_cloudwatch_event_rule.codecommit[0].name
  target_id = "CodePipeline"
  arn       = aws_codepipeline.main[0].arn
  role_arn  = aws_iam_role.eventbridge[0].arn
}

# IAM Role for EventBridge
resource "aws_iam_role" "eventbridge" {
  count = var.enable_codepipeline ? 1 : 0
  name  = "${var.project_name}-eventbridge-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-eventbridge-codepipeline-role"
      Purpose = "EventBridge role for CodePipeline"
    }
  )
}

# IAM Policy for EventBridge
resource "aws_iam_role_policy" "eventbridge" {
  count = var.enable_codepipeline ? 1 : 0
  name  = "${var.project_name}-eventbridge-codepipeline-policy"
  role  = aws_iam_role.eventbridge[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codepipeline:StartPipelineExecution"
        ]
        Resource = aws_codepipeline.main[0].arn
      }
    ]
  })
}
