output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.main[*].id
}

output "security_group_ids" {
  description = "Map of security group IDs by type"
  value = {
    web      = aws_security_group.web.id
    database = aws_security_group.database.id
    lambda   = aws_security_group.lambda.id
    ecs      = aws_security_group.ecs.id
  }
}

output "security_group_web_id" {
  description = "Web security group ID"
  value       = aws_security_group.web.id
}

output "security_group_database_id" {
  description = "Database security group ID"
  value       = aws_security_group.database.id
}

output "security_group_lambda_id" {
  description = "Lambda security group ID"
  value       = aws_security_group.lambda.id
}

output "security_group_ecs_id" {
  description = "ECS security group ID"
  value       = aws_security_group.ecs.id
}

output "estimated_cost" {
  description = "Estimated monthly cost for networking resources"
  value       = var.enable_nat_gateway ? length(var.availability_zones) * 32.40 : 0
}

output "vpc_endpoint_s3_id" {
  description = "S3 VPC Endpoint ID"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.s3[0].id : null
}

output "vpc_endpoint_dynamodb_id" {
  description = "DynamoDB VPC Endpoint ID"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.dynamodb[0].id : null
}

output "vpc_endpoint_lambda_id" {
  description = "Lambda VPC Endpoint ID"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.lambda[0].id : null
}

output "vpc_endpoints_security_group_id" {
  description = "VPC Endpoints security group ID"
  value       = var.enable_vpc_endpoints ? aws_security_group.vpc_endpoints[0].id : null
}
