# Cost Estimation and Validation Logic
# Updated to include all new service modules

locals {
  cost_estimates = {
    # ── Core Infrastructure ──────────────────────────────────────────────────
    # NAT Gateway: $32.40/AZ/month | Lambda VPC Endpoint: $7.30/month
    networking = var.enable_networking ? (
      (var.enable_nat_gateway ? 32.40 * length(local.availability_zones) : 0) +
      (var.enable_vpc_endpoints ? 7.30 : 0)
    ) : 0

    # Secrets Manager: $0.40/secret/month (5 secrets now)
    security = var.enable_security ? (5 * 0.40) : 0

    # EBS gp3 8GB: $0.704/month | S3: free tier
    storage = var.enable_storage ? 0.704 : 0

    # EC2 t2.micro: $8.35/month | Lambda: free tier
    compute = var.enable_compute ? 8.35 : 0

    # DynamoDB: free tier | RDS db.t3.micro: $14.71/month
    database = var.enable_database ? (var.enable_rds ? 14.71 : 0) : 0

    # SNS + SQS: free tier
    messaging = var.enable_messaging ? 0 : 0

    # CloudWatch alarms: $0.20 | CloudTrail S3: $0.023
    monitoring = var.enable_monitoring ? 0.223 : 0

    # API Gateway: free tier | VPC Link: $18.25/month
    api = var.enable_api ? (var.enable_vpc_link ? 18.25 : 0) : 0

    # ECS Fargate (minimal): $5.10/month | ECR: free tier
    container = var.enable_container ? 5.10 : 0

    # CodeCommit + CodeBuild: free tier | CodePipeline: $1.00/month
    code_services = var.enable_code_services ? (var.enable_codepipeline ? 1.00 : 0) : 0

    # Step Functions + EventBridge: free tier
    orchestration = var.enable_orchestration ? 0 : 0

    # Route53 hosted zone: $0.50/month
    route53 = var.enable_route53 && var.domain_name != "" ? 0.50 : 0

    # ── Extended Services ────────────────────────────────────────────────────
    # SSM Parameter Store: free tier
    ssm = var.enable_ssm ? 0 : 0

    # EIP: free when attached | ENI: free
    eip = var.enable_eip ? 0 : 0

    # SES: free tier (62,000 emails/month from EC2)
    ses = var.enable_ses ? 0 : 0

    # X-Ray: free tier (100,000 traces/month)
    xray = var.enable_xray ? 0 : 0

    # Cognito: free tier (50,000 MAU)
    cognito = var.enable_cognito ? 0 : 0

    # EFS: $0.30/GB-month, assume minimal usage ~0.1GB = $0.03/month
    efs = var.enable_efs ? 0.03 : 0

    # Kinesis Stream: $0.015/shard-hour = $10.80/month (1 shard)
    # Firehose: $0.029/GB, minimal = ~$0.03/month
    kinesis = var.enable_kinesis ? 10.83 : 0

    # WAFv2: $5.00/WebACL/month + $1.00/rule/month = ~$6.00/month
    waf = var.enable_waf ? 6.00 : 0

    # CloudFront: free tier (1TB transfer, 10M requests)
    cloudfront = var.enable_cloudfront ? 0 : 0

    # CodeDeploy: free for EC2/Lambda, $0.02/deployment for ECS
    codedeploy = var.enable_codedeploy ? 0 : 0

    # AWS Config: $0.003/config item recorded, ~$2/month for small infra
    config = var.enable_config ? 2.00 : 0

    # Resource Groups: free
    resourcegroups = var.enable_resourcegroups ? 0 : 0

    # IoT: free tier (250,000 messages/month)
    iot = var.enable_iot ? 0 : 0

    # Glue: free tier for catalog (1M objects), DPU only when jobs run
    glue = var.enable_glue ? 0 : 0

    # ECR Public: free
    ecrpublic = var.enable_ecrpublic ? 0 : 0

    # Access Analyzer: free
    accessanalyzer = var.enable_accessanalyzer ? 0 : 0

    # ACM: free for public certificates
    acm = var.enable_acm ? 0 : 0

    # ALB: $0.022/hour = $16.06/month | NLB: $0.006/hour = $4.38/month
    alb = var.enable_alb ? 20.44 : 0

    # AppSync: free tier (250,000 queries/month)
    appsync = var.enable_appsync ? 0 : 0

    # Batch: free (Fargate pricing only when jobs run)
    batch = var.enable_batch ? 0 : 0

    # Budgets: free (2 budgets free, $0.02/budget/day after)
    budgets = var.enable_budgets ? 0 : 0

    # CloudFormation: free
    cloudformation = var.enable_cloudformation ? 0 : 0

    # ElastiCache t3.micro: $0.017/hour = $12.41/month (cluster + replication group = $24.82)
    elasticache = var.enable_elasticache ? 24.82 : 0

    # Security Hub: $0.001/finding, ~$1/month for small infra
    securityhub = var.enable_securityhub ? 1.00 : 0

    # Service Catalog: free
    servicecatalog = var.enable_servicecatalog ? 0 : 0

    # SWF: free tier (10,000 activity tasks/month)
    swf = var.enable_swf ? 0 : 0

    # VPC Peering: free (data transfer costs only)
    vpc_peering = var.enable_vpc_peering ? 0 : 0

    # MQ mq.t3.micro: $0.027/hour = $19.71/month
    mq = var.enable_mq ? 19.71 : 0
  }

  total_estimated_cost = sum([for k, v in local.cost_estimates : v])
  cost_warning         = local.total_estimated_cost > (var.cost_limit * 0.8) ? "WARNING: Cost exceeds 80% of budget!" : ""

  cost_breakdown_text = format(<<-EOT
    ╔══════════════════════════════════════╗
    ║         COST BREAKDOWN               ║
    ╠══════════════════════════════════════╣
    ║ CORE INFRASTRUCTURE                  ║
    ║  Networking:       $%6.2f/month     ║
    ║  Security:         $%6.2f/month     ║
    ║  Storage:          $%6.2f/month     ║
    ║  Compute:          $%6.2f/month     ║
    ║  Database:         $%6.2f/month     ║
    ║  Messaging:        $%6.2f/month     ║
    ║  Monitoring:       $%6.2f/month     ║
    ║  API Gateway:      $%6.2f/month     ║
    ║  Container:        $%6.2f/month     ║
    ║  Code Services:    $%6.2f/month     ║
    ║  Orchestration:    $%6.2f/month     ║
    ║  Route53:          $%6.2f/month     ║
    ╠══════════════════════════════════════╣
    ║ EXTENDED SERVICES                    ║
    ║  SSM:              $%6.2f/month     ║
    ║  EIP/ENI:          $%6.2f/month     ║
    ║  SES:              $%6.2f/month     ║
    ║  X-Ray:            $%6.2f/month     ║
    ║  Cognito:          $%6.2f/month     ║
    ║  EFS:              $%6.2f/month     ║
    ║  Kinesis+Firehose: $%6.2f/month     ║
    ║  WAFv2:            $%6.2f/month     ║
    ║  CloudFront:       $%6.2f/month     ║
    ║  CodeDeploy:       $%6.2f/month     ║
    ║  AWS Config:       $%6.2f/month     ║
    ║  IoT:              $%6.2f/month     ║
    ║  Glue:             $%6.2f/month     ║
    ║  ALB+NLB:          $%6.2f/month     ║
    ║  AppSync:          $%6.2f/month     ║
    ║  ElastiCache:      $%6.2f/month     ║
    ║  Security Hub:     $%6.2f/month     ║
    ║  MQ:               $%6.2f/month     ║
    ╠══════════════════════════════════════╣
    ║  TOTAL:            $%6.2f/month     ║
    ║  BUDGET:           $%6.2f/month     ║
    ║  REMAINING:        $%6.2f/month     ║
    ╚══════════════════════════════════════╝
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
    local.cost_estimates.ssm,
    local.cost_estimates.eip,
    local.cost_estimates.ses,
    local.cost_estimates.xray,
    local.cost_estimates.cognito,
    local.cost_estimates.efs,
    local.cost_estimates.kinesis,
    local.cost_estimates.waf,
    local.cost_estimates.cloudfront,
    local.cost_estimates.codedeploy,
    local.cost_estimates.config,
    local.cost_estimates.iot,
    local.cost_estimates.glue,
    local.cost_estimates.alb,
    local.cost_estimates.appsync,
    local.cost_estimates.elasticache,
    local.cost_estimates.securityhub,
    local.cost_estimates.mq,
    local.total_estimated_cost,
    var.cost_limit,
    var.cost_limit - local.total_estimated_cost
  )
}

# Budget enforcement
resource "null_resource" "cost_validation" {
  lifecycle {
    precondition {
      condition     = local.total_estimated_cost <= var.cost_limit
      error_message = "Cost limit exceeded! Estimated: $${local.total_estimated_cost}/month, Limit: $${var.cost_limit}/month. Disable expensive modules: enable_alb, enable_kinesis, enable_waf, enable_elasticache, enable_mq."
    }
  }
}

output "cost_validation_status" {
  description = "Cost validation status"
  value = {
    estimated_cost = format("$%.2f", local.total_estimated_cost)
    budget_limit   = format("$%.2f", var.cost_limit)
    within_budget  = local.total_estimated_cost <= var.cost_limit
    utilization    = format("%.1f%%", (local.total_estimated_cost / var.cost_limit) * 100)
    remaining      = format("$%.2f", var.cost_limit - local.total_estimated_cost)
    warning        = local.cost_warning
  }
}

output "cost_breakdown_detailed" {
  description = "Detailed cost breakdown by module"
  value = {
    # Core
    networking    = { cost = local.cost_estimates.networking, enabled = var.enable_networking, details = var.enable_nat_gateway ? "NAT Gateway enabled" : (var.enable_vpc_endpoints ? "VPC Endpoints" : "Free tier") }
    security      = { cost = local.cost_estimates.security, enabled = var.enable_security, details = "5 Secrets Manager secrets" }
    storage       = { cost = local.cost_estimates.storage, enabled = var.enable_storage, details = "8GB EBS gp3" }
    compute       = { cost = local.cost_estimates.compute, enabled = var.enable_compute, details = "EC2 t2.micro + Lambda (VPC + public)" }
    database      = { cost = local.cost_estimates.database, enabled = var.enable_database, details = var.enable_rds ? "DynamoDB + RDS db.t3.micro" : "DynamoDB free tier" }
    messaging     = { cost = local.cost_estimates.messaging, enabled = var.enable_messaging, details = "SNS + SQS free tier" }
    monitoring    = { cost = local.cost_estimates.monitoring, enabled = var.enable_monitoring, details = "CloudWatch + CloudTrail" }
    api           = { cost = local.cost_estimates.api, enabled = var.enable_api, details = "API Gateway free tier" }
    container     = { cost = local.cost_estimates.container, enabled = var.enable_container, details = "ECS Fargate + ECR (3 repos)" }
    code_services = { cost = local.cost_estimates.code_services, enabled = var.enable_code_services, details = "CodeCommit + CodeBuild" }
    orchestration = { cost = local.cost_estimates.orchestration, enabled = var.enable_orchestration, details = "Step Functions + EventBridge (S3 trigger)" }
    route53       = { cost = local.cost_estimates.route53, enabled = var.enable_route53, details = "Hosted zone: ${var.domain_name}" }
    # Extended
    ssm         = { cost = local.cost_estimates.ssm, enabled = var.enable_ssm, details = "SSM Parameter Store free tier" }
    eip         = { cost = local.cost_estimates.eip, enabled = var.enable_eip, details = "EIP + ENI free" }
    ses         = { cost = local.cost_estimates.ses, enabled = var.enable_ses, details = "SES free tier" }
    xray        = { cost = local.cost_estimates.xray, enabled = var.enable_xray, details = "X-Ray free tier" }
    cognito     = { cost = local.cost_estimates.cognito, enabled = var.enable_cognito, details = "Cognito free tier (50K MAU)" }
    efs         = { cost = local.cost_estimates.efs, enabled = var.enable_efs, details = "EFS minimal usage" }
    kinesis     = { cost = local.cost_estimates.kinesis, enabled = var.enable_kinesis, details = "1 Kinesis shard + Firehose" }
    waf         = { cost = local.cost_estimates.waf, enabled = var.enable_waf, details = "WAFv2 WebACL + rules" }
    cloudfront  = { cost = local.cost_estimates.cloudfront, enabled = var.enable_cloudfront, details = "CloudFront free tier" }
    config      = { cost = local.cost_estimates.config, enabled = var.enable_config, details = "AWS Config recorder + rules" }
    alb         = { cost = local.cost_estimates.alb, enabled = var.enable_alb, details = "ALB ($16.06) + NLB ($4.38)" }
    appsync     = { cost = local.cost_estimates.appsync, enabled = var.enable_appsync, details = "AppSync free tier" }
    elasticache = { cost = local.cost_estimates.elasticache, enabled = var.enable_elasticache, details = "Redis cluster + replication group" }
    securityhub = { cost = local.cost_estimates.securityhub, enabled = var.enable_securityhub, details = "Security Hub findings" }
    mq          = { cost = local.cost_estimates.mq, enabled = var.enable_mq, details = "Amazon MQ mq.t3.micro" }
  }
}

output "cost_optimization_suggestions" {
  description = "Suggestions to reduce costs if over budget"
  value = local.total_estimated_cost > var.cost_limit ? [
    format("Disable ALB/NLB (saves $%.2f/month)", local.cost_estimates.alb),
    format("Disable Kinesis (saves $%.2f/month)", local.cost_estimates.kinesis),
    format("Disable WAFv2 (saves $%.2f/month)", local.cost_estimates.waf),
    format("Disable ElastiCache (saves $%.2f/month)", local.cost_estimates.elasticache),
    format("Disable MQ (saves $%.2f/month)", local.cost_estimates.mq),
    format("Disable RDS (saves $%.2f/month)", local.cost_estimates.database),
    format("Disable NAT Gateway (saves $%.2f/month)", 32.40 * length(local.availability_zones)),
  ] : ["No optimization needed - within budget"]
}
