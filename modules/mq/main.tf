# MQ Module - Amazon MQ (ActiveMQ, smallest instance)

resource "aws_mq_broker" "main" {
  broker_name        = "${var.project_name}-mq"
  engine_type        = "ActiveMQ"
  engine_version     = "5.17.6"
  host_instance_type = "mq.t3.micro"
  deployment_mode    = "SINGLE_INSTANCE"
  publicly_accessible = false

  subnet_ids         = [var.subnet_id]
  security_groups    = [var.security_group_id]

  user {
    username = "admin"
    password = var.mq_password
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-mq" })
}
