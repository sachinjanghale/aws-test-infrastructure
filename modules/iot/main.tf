# IoT Module

resource "aws_iot_thing_type" "main" {
  name = "${var.project_name}-device-type"

  properties {
    description = "IoT device type for ${var.project_name}"
  }
}

resource "aws_iot_thing" "main" {
  name            = "${var.project_name}-device-001"
  thing_type_name = aws_iot_thing_type.main.name

  attributes = {
    project = var.project_name
    env     = "test"
  }
}

resource "aws_iot_role_alias" "main" {
  alias    = "${var.project_name}-iot-alias"
  role_arn = var.iot_role_arn
}

resource "aws_iot_topic_rule" "main" {
  name        = replace("${var.project_name}_iot_rule", "-", "_")
  description = "IoT topic rule for ${var.project_name}"
  enabled     = true
  sql         = "SELECT * FROM 'iot/${var.project_name}/telemetry'"
  sql_version = "2016-03-23"

  lambda {
    function_arn = var.lambda_function_arn
  }
}
