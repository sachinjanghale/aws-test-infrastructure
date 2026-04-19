# CodeDeploy Module

resource "aws_codedeploy_app" "ec2" {
  name             = "${var.project_name}-ec2-app"
  compute_platform = "Server"
}

resource "aws_codedeploy_app" "lambda" {
  name             = "${var.project_name}-lambda-app"
  compute_platform = "Lambda"
}

resource "aws_codedeploy_app" "ecs" {
  name             = "${var.project_name}-ecs-app"
  compute_platform = "ECS"
}
