# API Module - API Gateway REST API

# API Gateway REST API
resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.project_name}-api"
  description = "REST API for ${var.project_name}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-api"
      Purpose = "REST API Gateway"
    }
  )
}

# API Gateway Resource - /hello
resource "aws_api_gateway_resource" "hello" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "hello"
}

# API Gateway Resource - /data
resource "aws_api_gateway_resource" "data" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "data"
}

# API Gateway Method - GET /hello
resource "aws_api_gateway_method" "hello_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = "GET"
  authorization = "NONE"
}

# API Gateway Method - POST /data
resource "aws_api_gateway_method" "data_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.data.id
  http_method   = "POST"
  authorization = "NONE"
}

# API Gateway Integration - GET /hello -> Python Lambda
resource "aws_api_gateway_integration" "hello_get" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.hello.id
  http_method             = aws_api_gateway_method.hello_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${var.lambda_function_arns["python"]}/invocations"
}

# API Gateway Integration - POST /data -> Node.js Lambda
resource "aws_api_gateway_integration" "data_post" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.data.id
  http_method             = aws_api_gateway_method.data_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${var.lambda_function_arns["nodejs"]}/invocations"
}

# Lambda Permission for API Gateway - Python Lambda
resource "aws_lambda_permission" "api_gateway_python" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names["python"]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# Lambda Permission for API Gateway - Node.js Lambda
resource "aws_lambda_permission" "api_gateway_nodejs" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names["nodejs"]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.hello.id,
      aws_api_gateway_resource.data.id,
      aws_api_gateway_method.hello_get.id,
      aws_api_gateway_method.data_post.id,
      aws_api_gateway_integration.hello_get.id,
      aws_api_gateway_integration.data_post.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.hello_get,
    aws_api_gateway_integration.data_post
  ]
}

# API Gateway Stage
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = "dev"

  xray_tracing_enabled = true

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-api-dev-stage"
      Purpose = "Development stage for API Gateway"
    }
  )
}

# API Gateway Method Settings
resource "aws_api_gateway_method_settings" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.main.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled    = true
    logging_level      = "INFO"
    data_trace_enabled = true
  }
}

# API Gateway Authorizer (Token-based)
resource "aws_api_gateway_authorizer" "token" {
  name                   = "${var.project_name}-token-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.main.id
  type                   = "TOKEN"
  authorizer_uri         = "${var.lambda_function_arns["python"]}/invocations"
  authorizer_credentials = var.api_gateway_role_arn
  identity_source        = "method.request.header.Authorization"
}

# API Gateway API Key
resource "aws_api_gateway_api_key" "main" {
  name    = "${var.project_name}-api-key"
  enabled = true

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-api-key"
      Purpose = "API key for usage plan"
    }
  )
}

# API Gateway Usage Plan
resource "aws_api_gateway_usage_plan" "main" {
  name        = "${var.project_name}-usage-plan"
  description = "Usage plan for ${var.project_name} API"

  api_stages {
    api_id = aws_api_gateway_rest_api.main.id
    stage  = aws_api_gateway_stage.main.stage_name
  }

  quota_settings {
    limit  = 10000
    period = "MONTH"
  }

  throttle_settings {
    burst_limit = 100
    rate_limit  = 50
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-usage-plan"
      Purpose = "API usage plan with quotas and throttling"
    }
  )
}

# API Gateway Usage Plan Key
resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.main.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.main.id
}

# API Gateway Model
resource "aws_api_gateway_model" "request_model" {
  rest_api_id  = aws_api_gateway_rest_api.main.id
  name         = "RequestModel"
  description  = "Request model for API"
  content_type = "application/json"

  schema = jsonencode({
    type = "object"
    properties = {
      message = {
        type = "string"
      }
      timestamp = {
        type = "string"
      }
    }
    required = ["message"]
  })
}

# API Gateway Gateway Response (for 4xx errors)
resource "aws_api_gateway_gateway_response" "unauthorized" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  response_type = "UNAUTHORIZED"
  status_code   = "401"

  response_templates = {
    "application/json" = jsonencode({
      message = "Unauthorized"
      error   = "$context.error.messageString"
    })
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'"
  }
}

# API Gateway Documentation Part
resource "aws_api_gateway_documentation_part" "api_description" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  location {
    type = "API"
  }

  properties = jsonencode({
    description = "API for ${var.project_name} - Test infrastructure for migration tool"
    version     = "1.0"
  })
}

# API Gateway Method Response for GET /hello
resource "aws_api_gateway_method_response" "hello_get_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.hello_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

# API Gateway Integration Response for GET /hello
resource "aws_api_gateway_integration_response" "hello_get" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.hello_get.http_method
  status_code = aws_api_gateway_method_response.hello_get_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.hello_get]
}

# API Gateway VPC Link (optional - has cost)
resource "aws_api_gateway_vpc_link" "main" {
  count       = var.enable_vpc_link ? 1 : 0
  name        = "${var.project_name}-vpc-link"
  description = "VPC Link for private integrations"
  target_arns = var.nlb_arn != "" ? [var.nlb_arn] : []

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-vpc-link"
      Purpose = "VPC Link for private API integrations"
    }
  )
}
