# Batch Module

resource "aws_batch_compute_environment" "main" {
  compute_environment_name = "${var.project_name}-batch-env"
  type                     = "MANAGED"
  state                    = "ENABLED"
  service_role             = var.batch_service_role_arn

  compute_resources {
    type               = "FARGATE"
    max_vcpus          = 4
    subnets            = var.subnet_ids
    security_group_ids = [var.security_group_id]
  }
}

resource "aws_batch_job_queue" "main" {
  name     = "${var.project_name}-batch-queue"
  state    = "ENABLED"
  priority = 1

  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.main.arn
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-batch-queue" })
}

resource "aws_batch_job_definition" "main" {
  name = "${var.project_name}-batch-job"
  type = "container"

  platform_capabilities = ["FARGATE"]

  container_properties = jsonencode({
    image   = "public.ecr.aws/amazonlinux/amazonlinux:latest"
    command = ["echo", "Hello from Batch"]

    fargatePlatformConfiguration = {
      platformVersion = "LATEST"
    }

    resourceRequirements = [
      { type = "VCPU", value = "0.25" },
      { type = "MEMORY", value = "512" }
    ]

    executionRoleArn = var.batch_execution_role_arn

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"  = "/aws/batch/${var.project_name}"
        "awslogs-region" = var.aws_region
      }
    }
  })

  tags = merge(var.common_tags, { Name = "${var.project_name}-batch-job" })
}
