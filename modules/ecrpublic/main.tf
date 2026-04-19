# ECR Public Module (Global service)

resource "aws_ecrpublic_repository" "main" {
  repository_name = "${var.project_name}-public"

  catalog_data {
    about_text        = "Public repository for ${var.project_name}"
    architectures     = ["x86-64"]
    operating_systems = ["Linux"]
    usage_text        = "Test public ECR repository"
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-ecr-public" })
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
