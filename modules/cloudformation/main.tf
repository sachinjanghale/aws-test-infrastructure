# CloudFormation Module

resource "aws_cloudformation_stack" "main" {
  name = "${var.project_name}-cfn-stack"

  template_body = jsonencode({
    AWSTemplateFormatVersion = "2010-09-09"
    Description              = "Test CloudFormation stack for ${var.project_name}"
    Resources = {
      TestBucket = {
        Type = "AWS::S3::Bucket"
        Properties = {
          BucketName = "${var.project_name}-cfn-bucket-${var.account_id}"
          Tags = [
            { Key = "Project", Value = var.project_name },
            { Key = "ManagedBy", Value = "CloudFormation" }
          ]
        }
      }
    }
    Outputs = {
      BucketName = {
        Value       = { Ref = "TestBucket" }
        Description = "CloudFormation managed S3 bucket"
      }
    }
  })

  tags = merge(var.common_tags, { Name = "${var.project_name}-cfn-stack" })
}
