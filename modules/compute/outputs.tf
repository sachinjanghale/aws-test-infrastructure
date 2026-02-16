output "lambda_function_arns" {
  description = "List of Lambda function ARNs"
  value = [
    aws_lambda_function.python_function.arn,
    aws_lambda_function.nodejs_function.arn
  ]
}

output "lambda_function_names" {
  description = "List of Lambda function names"
  value = [
    aws_lambda_function.python_function.function_name,
    aws_lambda_function.nodejs_function.function_name
  ]
}

output "python_lambda_arn" {
  description = "Python Lambda function ARN"
  value       = aws_lambda_function.python_function.arn
}

output "python_lambda_name" {
  description = "Python Lambda function name"
  value       = aws_lambda_function.python_function.function_name
}

output "nodejs_lambda_arn" {
  description = "Node.js Lambda function ARN"
  value       = aws_lambda_function.nodejs_function.arn
}

output "nodejs_lambda_name" {
  description = "Node.js Lambda function name"
  value       = aws_lambda_function.nodejs_function.function_name
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

output "ec2_instance_public_ip" {
  description = "EC2 instance public IP"
  value       = aws_instance.web.public_ip
}

output "ec2_instance_private_ip" {
  description = "EC2 instance private IP"
  value       = aws_instance.web.private_ip
}

output "ec2_key_pair_name" {
  description = "EC2 key pair name"
  value       = aws_key_pair.ec2_key.key_name
}

output "ec2_private_key_pem" {
  description = "EC2 private key in PEM format (sensitive)"
  value       = tls_private_key.ec2_key.private_key_pem
  sensitive   = true
}

output "ec2_private_key_file" {
  description = "Path to EC2 private key file"
  value       = local_file.private_key.filename
}

output "launch_template_id" {
  description = "Launch template ID"
  value       = aws_launch_template.web.id
}

output "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.web.name
}

output "autoscaling_group_arn" {
  description = "Auto Scaling Group ARN"
  value       = aws_autoscaling_group.web.arn
}

output "estimated_cost" {
  description = "Estimated monthly cost for compute resources"
  value       = 8.35 # t2.micro 24/7: $0.0116/hour * 730 hours
}
