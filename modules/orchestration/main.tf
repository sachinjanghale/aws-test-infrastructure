# Orchestration Module - Step Functions and EventBridge

# Step Functions State Machine
resource "aws_sfn_state_machine" "main" {
  name     = "${var.project_name}-state-machine"
  role_arn = var.step_function_role_arn

  definition = jsonencode({
    Comment = "State machine for ${var.project_name}"
    StartAt = "InvokeLambda1"
    States = {
      InvokeLambda1 = {
        Type     = "Task"
        Resource = length(var.lambda_function_arns) > 0 ? var.lambda_function_arns[0] : "arn:aws:lambda:*:*:function:placeholder"
        Next     = "Wait"
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "HandleError"
          }
        ]
      }
      Wait = {
        Type    = "Wait"
        Seconds = 5
        Next    = "InvokeLambda2"
      }
      InvokeLambda2 = {
        Type     = "Task"
        Resource = length(var.lambda_function_arns) > 1 ? var.lambda_function_arns[1] : "arn:aws:lambda:*:*:function:placeholder"
        Next     = "Success"
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "HandleError"
          }
        ]
      }
      HandleError = {
        Type = "Pass"
        Result = {
          error = "An error occurred during execution"
        }
        Next = "Fail"
      }
      Success = {
        Type = "Succeed"
      }
      Fail = {
        Type = "Fail"
      }
    }
  })

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.step_functions.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-state-machine"
      Purpose = "Step Functions state machine for workflow orchestration"
    }
  )
}

# CloudWatch Log Group for Step Functions
resource "aws_cloudwatch_log_group" "step_functions" {
  name              = "/aws/states/${var.project_name}"
  retention_in_days = 7

  tags = merge(
    var.common_tags,
    {
      Name    = "/aws/states/${var.project_name}"
      Purpose = "Log group for Step Functions"
    }
  )
}

# EventBridge Rule 1 - Scheduled (every 6 hours)
resource "aws_cloudwatch_event_rule" "scheduled_6h" {
  name                = "${var.project_name}-scheduled-6h"
  description         = "Trigger Lambda every 6 hours"
  schedule_expression = "rate(6 hours)"

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-scheduled-6h"
      Purpose = "EventBridge rule for scheduled Lambda invocation"
    }
  )
}

# EventBridge Rule 2 - Scheduled (daily at midnight UTC)
resource "aws_cloudwatch_event_rule" "scheduled_daily" {
  name                = "${var.project_name}-scheduled-daily"
  description         = "Trigger Lambda daily at midnight UTC"
  schedule_expression = "cron(0 0 * * ? *)"

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-scheduled-daily"
      Purpose = "EventBridge rule for daily Lambda invocation"
    }
  )
}

# EventBridge Target 1 - Lambda Function
resource "aws_cloudwatch_event_target" "lambda_6h" {
  count     = length(var.lambda_function_arns) > 0 ? 1 : 0
  rule      = aws_cloudwatch_event_rule.scheduled_6h.name
  target_id = "Lambda6h"
  arn       = var.lambda_function_arns[0]

  input = jsonencode({
    source      = "eventbridge"
    schedule    = "6-hours"
    description = "Scheduled invocation every 6 hours"
  })
}

# EventBridge Target 2 - Lambda Function
resource "aws_cloudwatch_event_target" "lambda_daily" {
  count     = length(var.lambda_function_arns) > 1 ? 1 : 0
  rule      = aws_cloudwatch_event_rule.scheduled_daily.name
  target_id = "LambdaDaily"
  arn       = var.lambda_function_arns[1]

  input = jsonencode({
    source      = "eventbridge"
    schedule    = "daily"
    description = "Scheduled invocation daily at midnight UTC"
  })
}

# EventBridge Target 3 - Step Functions
resource "aws_cloudwatch_event_target" "step_functions" {
  rule      = aws_cloudwatch_event_rule.scheduled_daily.name
  target_id = "StepFunctionsDaily"
  arn       = aws_sfn_state_machine.main.arn
  role_arn  = aws_iam_role.eventbridge_step_functions.arn

  input = jsonencode({
    source      = "eventbridge"
    schedule    = "daily"
    description = "Scheduled Step Functions execution"
  })
}

# Lambda Permission for EventBridge - 6h schedule
resource "aws_lambda_permission" "eventbridge_6h" {
  count         = length(var.lambda_function_arns) > 0 ? 1 : 0
  statement_id  = "AllowEventBridge6h"
  action        = "lambda:InvokeFunction"
  function_name = element(split(":", var.lambda_function_arns[0]), 6)
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scheduled_6h.arn
}

# Lambda Permission for EventBridge - daily schedule
resource "aws_lambda_permission" "eventbridge_daily" {
  count         = length(var.lambda_function_arns) > 1 ? 1 : 0
  statement_id  = "AllowEventBridgeDaily"
  action        = "lambda:InvokeFunction"
  function_name = element(split(":", var.lambda_function_arns[1]), 6)
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scheduled_daily.arn
}

# IAM Role for EventBridge to invoke Step Functions
resource "aws_iam_role" "eventbridge_step_functions" {
  name = "${var.project_name}-eventbridge-sfn-role"

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
      Name    = "${var.project_name}-eventbridge-sfn-role"
      Purpose = "EventBridge role for Step Functions invocation"
    }
  )
}

# IAM Policy for EventBridge to invoke Step Functions
resource "aws_iam_role_policy" "eventbridge_step_functions" {
  name = "${var.project_name}-eventbridge-sfn-policy"
  role = aws_iam_role.eventbridge_step_functions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "states:StartExecution"
        ]
        Resource = aws_sfn_state_machine.main.arn
      }
    ]
  })
}
