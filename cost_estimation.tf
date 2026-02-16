# Cost Estimation and Validation Logic
# This file calculates estimated monthly costs for all modules and enforces budget limits

locals {
  # Cost estimates per module (in USD per month)
  # Based on AWS pricing as of 2024 for ap-south-1 region

  cost_estimates = {
    # Networking: VPC, Subnets, IGW, Security Groups are free
    # NAT Gateway: ~$0.045/hour = ~$32.40/month per AZ (if enabled)
    # VPC Interface Endpoints: $0.01/hour = ~$7.30/month per endpoint
    # Gateway Endpoints (S3, DynamoDB): Free
    networking = var.enable_networking ? (
      (var.enable_nat_gateway ? 32.40 * length(local.availability_zones) : 0) +
      (var.enable_vpc_endpoints ? 7.30 : 0) # Lambda interface endpoint
    ) : 0

    # Security: IAM is free, KMS key is free (pay per API call)
    # Secrets Manager: $0.40 per secret per month
    security = var.enable_security ? (2 * 0.40) : 0

    # Storage: S3 is free tier (5GB), EBS gp3 $0.088/GB-month
    # 8GB EBS volume = $0.704/month
    storage = var.enable_storage ? 0.704 : 0

    # Compute: Lambda free tier (1M requests), EC2 t2.micro
    # t2.micro: $0.0116/hour = ~$8.35/month (730 hours)
    # Auto Scaling Group uses same instance, no additional cost
    compute = var.enable_compute ? 8.35 : 0

    # Database: DynamoDB free tier (25GB, 25 RCU/WCU)
    # RDS db.t3.micro: $0.017/hour = ~$12.41/month (if enabled)
    # RDS storage: 20GB * $0.115/GB-month = $2.30/month
    database = var.enable_database ? (var.enable_rds ? 12.41 + 2.30 : 0) : 0

    # Messaging: SNS and SQS free tier (1M requests each)
    messaging = var.enable_messaging ? 0 : 0

    # Monitoring: CloudWatch Logs free tier (5GB ingestion)
    # CloudTrail: First trail is free, S3 storage ~$0.023/GB
    # Estimated 1GB logs/month = $0.023
    # CloudWatch Alarms: $0.10 per alarm (2 alarms) = $0.20
    monitoring = var.enable_monitoring ? 0.223 : 0

    # API: API Gateway free tier (1M requests)
    # VPC Link: $0.025/hour = ~$18.25/month (if enabled)
    api = var.enable_api ? (var.enable_vpc_link ? 18.25 : 0) : 0

    # Container: ECR storage $0.10/GB-month (assume 1GB)
    # ECS Fargate: $0.04048/vCPU-hour + $0.004445/GB-hour
    # 0.25 vCPU * 730 hours = $7.39
    # 0.5 GB * 730 hours = $1.62
    # Total: ~$9.01/month (but we'll run minimal hours for testing)
    # Estimated for testing: ~$5/month
    container = var.enable_container ? 5.10 : 0

    # Code Services: CodeCommit free tier (5 users, 50GB storage)
    # CodeBuild: 100 build minutes/month free
    # CodePipeline: $1/active pipeline/month (if enabled)
    code_services = var.enable_code_services ? (var.enable_codepipeline ? 1.00 : 0) : 0

    # Orchestration: Step Functions free tier (4,000 state transitions)
    # EventBridge: Free for AWS service events
    orchestration = var.enable_orchestration ? 0 : 0

    # Route53: $0.50 per hosted zone per month
    # Queries: First 1 billion queries/month are $0.40 per million (negligible for testing)
    route53 = var.enable_route53 && var.domain_name != "" ? 0.50 : 0
  }

  # Calculate total estimated cost
  total_estimated_cost = sum([for k, v in local.cost_estimates : v])

  # Cost validation messages
  cost_warning = local.total_estimated_cost > (var.cost_limit * 0.8) ? "Warning: Estimated cost exceeds 80% of budget limit" : ""

  cost_breakdown_text = format(<<-EOT
    === Cost Breakdown ===
    Networking:    $%.2f
    Security:      $%.2f
    Storage:       $%.2f
    Compute:       $%.2f
    Database:      $%.2f
    Messaging:     $%.2f
    Monitoring:    $%.2f
    API:           $%.2f
    Container:     $%.2f
    Code Services: $%.2f
    Orchestration: $%.2f
    Route53:       $%.2f
    =====================
    Total:         $%.2f
    Budget Limit:  $%.2f
    Remaining:     $%.2f
  EOT
    ,
    local.cost_estimates.networking,
    local.cost_estimates.security,
    local.cost_estimates.storage,
    local.cost_estimates.compute,
    local.cost_estimates.database,
    local.cost_estimates.messaging,
    local.cost_estimates.monitoring,
    local.cost_estimates.api,
    local.cost_estimates.container,
    local.cost_estimates.code_services,
    local.cost_estimates.orchestration,
    local.cost_estimates.route53,
    local.total_estimated_cost,
    var.cost_limit,
    var.cost_limit - local.total_estimated_cost
  )
}

# Precondition check to enforce cost limit
resource "null_resource" "cost_validation" {
  lifecycle {
    precondition {
      condition = local.total_estimated_cost <= var.cost_limit
      error_message = format(<<-EOT
        Cost limit exceeded!
        
        %s
        
        The estimated monthly cost ($%.2f) exceeds your budget limit ($%.2f).
        
        To reduce costs, consider:
        1. Disable expensive modules (enable_rds, enable_nat_gateway)
        2. Disable optional modules (enable_container, enable_code_services)
        3. Increase the cost_limit variable if you have budget available
        
        Current expensive options:
        - RDS: %s
        - NAT Gateway: %s
        - CodePipeline: %s
      EOT
        ,
        local.cost_breakdown_text,
        local.total_estimated_cost,
        var.cost_limit,
        var.enable_rds ? "ENABLED (+$14.71/month)" : "disabled",
        var.enable_nat_gateway ? format("ENABLED (+$%.2f/month)", 32.40 * length(local.availability_zones)) : "disabled",
        var.enable_codepipeline ? "ENABLED (+$1.00/month)" : "disabled"
      )
    }
  }
}

# Output cost information
output "cost_validation_status" {
  description = "Cost validation status"
  value = {
    estimated_cost = local.total_estimated_cost
    budget_limit   = var.cost_limit
    within_budget  = local.total_estimated_cost <= var.cost_limit
    utilization    = format("%.1f%%", (local.total_estimated_cost / var.cost_limit) * 100)
    warning        = local.cost_warning
  }
}

output "cost_breakdown_detailed" {
  description = "Detailed cost breakdown by module"
  value = {
    networking = {
      enabled = var.enable_networking
      cost    = local.cost_estimates.networking
      details = var.enable_nat_gateway ? "Includes NAT Gateway" : (var.enable_vpc_endpoints ? "Includes Lambda VPC Endpoint" : "Free tier only")
    }
    security = {
      enabled = var.enable_security
      cost    = local.cost_estimates.security
      details = "2 Secrets Manager secrets"
    }
    storage = {
      enabled = var.enable_storage
      cost    = local.cost_estimates.storage
      details = "8GB EBS volume"
    }
    compute = {
      enabled = var.enable_compute
      cost    = local.cost_estimates.compute
      details = "1 t2.micro EC2 instance (24/7)"
    }
    database = {
      enabled = var.enable_database
      cost    = local.cost_estimates.database
      details = var.enable_rds ? "DynamoDB + RDS db.t3.micro" : "DynamoDB only (free tier)"
    }
    messaging = {
      enabled = var.enable_messaging
      cost    = local.cost_estimates.messaging
      details = "SNS + SQS (free tier)"
    }
    monitoring = {
      enabled = var.enable_monitoring
      cost    = local.cost_estimates.monitoring
      details = "CloudWatch + CloudTrail"
    }
    api = {
      enabled = var.enable_api
      cost    = local.cost_estimates.api
      details = "API Gateway (free tier)"
    }
    container = {
      enabled = var.enable_container
      cost    = local.cost_estimates.container
      details = "ECR + ECS Fargate (minimal)"
    }
    code_services = {
      enabled = var.enable_code_services
      cost    = local.cost_estimates.code_services
      details = var.enable_codepipeline ? "CodeCommit + CodeBuild + CodePipeline" : "CodeCommit + CodeBuild (free tier)"
    }
    orchestration = {
      enabled = var.enable_orchestration
      cost    = local.cost_estimates.orchestration
      details = "Step Functions + EventBridge (free tier)"
    }
    route53 = {
      enabled = var.enable_route53 && var.domain_name != ""
      cost    = local.cost_estimates.route53
      details = "Hosted zone for ${var.domain_name != "" ? var.domain_name : "domain"}"
    }
  }
}

# Cost optimization suggestions
output "cost_optimization_suggestions" {
  description = "Suggestions to reduce costs"
  value = local.total_estimated_cost > var.cost_limit ? [
    "Disable RDS (saves $14.71/month)",
    format("Disable NAT Gateway (saves $%.2f/month)", 32.40 * length(local.availability_zones)),
    "Disable Container module (saves $5.10/month)",
    "Disable CodePipeline (saves $1.00/month)",
  ] : ["No optimization needed - within budget"]
}
