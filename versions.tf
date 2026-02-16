terraform {
  required_version = ">= 1.12.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.98.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # Backend configuration for state management
  # Uncomment and configure after creating S3 bucket and DynamoDB table
  # backend "s3" {
  #   bucket         = "infrasyn-terraform-state"
  #   key            = "test-infrastructure/terraform.tfstate"
  #   region         = "ap-south-1"
  #   dynamodb_table = "infrasyn-terraform-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "test"
      ManagedBy   = "terraform"
      CostCenter  = "infrasyn-testing"
    }
  }
}
