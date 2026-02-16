# Compute Module - Lambda Functions, EC2, Auto Scaling

# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# TLS Private Key for EC2 SSH access
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# AWS Key Pair
resource "aws_key_pair" "ec2_key" {
  key_name   = "${var.project_name}-ec2-key"
  public_key = tls_private_key.ec2_key.public_key_openssh

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-ec2-key"
      Purpose = "SSH key pair for EC2 instances"
    }
  )
}

# Store private key in local file (for testing purposes only)
resource "local_file" "private_key" {
  content         = tls_private_key.ec2_key.private_key_pem
  filename        = "${path.root}/${var.project_name}-ec2-key.pem"
  file_permission = "0400"
}

# Lambda Function 1 - Python
resource "aws_lambda_function" "python_function" {
  filename         = data.archive_file.python_lambda.output_path
  function_name    = "${var.project_name}-python-function"
  role             = var.lambda_execution_role_arn
  handler          = "index.lambda_handler"
  source_code_hash = data.archive_file.python_lambda.output_base64sha256
  runtime          = "python3.11"
  timeout          = 30
  memory_size      = 128

  environment {
    variables = {
      PROJECT_NAME = var.project_name
      ENVIRONMENT  = "test"
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-python-function"
      Purpose = "Python Lambda function for testing"
      Runtime = "python3.11"
    }
  )
}

# Lambda Function 2 - Node.js
resource "aws_lambda_function" "nodejs_function" {
  filename         = data.archive_file.nodejs_lambda.output_path
  function_name    = "${var.project_name}-nodejs-function"
  role             = var.lambda_execution_role_arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.nodejs_lambda.output_base64sha256
  runtime          = "nodejs20.x"
  timeout          = 30
  memory_size      = 128

  environment {
    variables = {
      PROJECT_NAME = var.project_name
      ENVIRONMENT  = "test"
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-nodejs-function"
      Purpose = "Node.js Lambda function for testing"
      Runtime = "nodejs20.x"
    }
  )
}

# Create Lambda deployment packages
resource "local_file" "python_lambda_code" {
  content  = <<-EOT
import json
import os

def lambda_handler(event, context):
    project_name = os.environ.get('PROJECT_NAME', 'unknown')
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': f'Hello from {project_name} Python Lambda!',
            'event': event
        })
    }
EOT
  filename = "${path.module}/lambda_functions/python/index.py"
}

resource "local_file" "nodejs_lambda_code" {
  content  = <<-EOT
exports.handler = async (event) => {
    const projectName = process.env.PROJECT_NAME || 'unknown';
    return {
        statusCode: 200,
        body: JSON.stringify({
            message: `Hello from $${projectName} Node.js Lambda!`,
            event: event
        })
    };
};
EOT
  filename = "${path.module}/lambda_functions/nodejs/index.js"
}

data "archive_file" "python_lambda" {
  type        = "zip"
  source_file = local_file.python_lambda_code.filename
  output_path = "${path.module}/lambda_functions/python_function.zip"
  depends_on  = [local_file.python_lambda_code]
}

data "archive_file" "nodejs_lambda" {
  type        = "zip"
  source_file = local_file.nodejs_lambda_code.filename
  output_path = "${path.module}/lambda_functions/nodejs_function.zip"
  depends_on  = [local_file.nodejs_lambda_code]
}

# EC2 Instance (t2.micro)
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.ec2_instance_profile_name
  key_name               = aws_key_pair.ec2_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from ${var.project_name} EC2 Instance</h1>" > /var/www/html/index.html
              
              # Install CloudWatch agent
              wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
              rpm -U ./amazon-cloudwatch-agent.rpm
              EOF

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-web-server"
      Purpose = "Web server for testing"
      Type    = "t2.micro"
    }
  )
}

# Attach EBS volume to EC2 instance
resource "aws_volume_attachment" "data" {
  device_name = "/dev/sdf"
  volume_id   = var.ebs_volume_id
  instance_id = aws_instance.web.id
}

# Launch Template for Auto Scaling
resource "aws_launch_template" "web" {
  name_prefix   = "${var.project_name}-web-lt-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"

  iam_instance_profile {
    name = var.ec2_instance_profile_name
  }

  vpc_security_group_ids = [var.security_group_id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from ${var.project_name} Auto Scaling Instance</h1>" > /var/www/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.common_tags,
      {
        Name    = "${var.project_name}-asg-instance"
        Purpose = "Auto Scaling Group instance"
      }
    )
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.project_name}-launch-template"
      Purpose = "Launch template for Auto Scaling Group"
    }
  )
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web" {
  name                      = "${var.project_name}-asg"
  vpc_zone_identifier       = var.public_subnet_ids
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg"
    propagate_at_launch = false
  }

  tag {
    key                 = "Purpose"
    value               = "Auto Scaling Group for web servers"
    propagate_at_launch = false
  }

  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = false
    }
  }
}

# Lambda Layer Version
resource "aws_lambda_layer_version" "utils" {
  filename            = data.archive_file.lambda_layer.output_path
  layer_name          = "${var.project_name}-utils-layer"
  compatible_runtimes = ["python3.11", "python3.10"]
  source_code_hash    = data.archive_file.lambda_layer.output_base64sha256

  description = "Utility layer for Lambda functions"
}

# Create layer code
resource "local_file" "layer_code" {
  filename = "${path.module}/lambda_layer/python/utils.py"
  content  = <<-EOT
    def format_response(status_code, body):
        return {
            'statusCode': status_code,
            'body': body,
            'headers': {
                'Content-Type': 'application/json'
            }
        }
  EOT
}

# Archive layer code
data "archive_file" "lambda_layer" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_layer"
  output_path = "${path.module}/lambda_layer.zip"

  depends_on = [local_file.layer_code]
}

# Lambda Function Event Invoke Config
resource "aws_lambda_function_event_invoke_config" "python_config" {
  function_name = aws_lambda_function.python_function.function_name

  maximum_event_age_in_seconds = 3600
  maximum_retry_attempts       = 1

  destination_config {
    on_failure {
      destination = var.sqs_dlq_arn != "" ? var.sqs_dlq_arn : null
    }
  }
}

# Lambda Event Source Mapping (for SQS)
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  count            = var.sqs_queue_arn != "" ? 1 : 0
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.python_function.arn
  batch_size       = 10
  enabled          = true
}

# Launch Configuration (deprecated but still supported)
resource "aws_launch_configuration" "web" {
  name_prefix   = "${var.project_name}-lc-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"

  security_groups = [var.security_group_id]

  iam_instance_profile = var.ec2_instance_profile_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Launch Configuration</h1>" > /var/www/html/index.html
              EOF

  lifecycle {
    create_before_destroy = true
  }
}
