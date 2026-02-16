# Cost Estimation Guide

This document provides detailed cost estimates for the AWS test infrastructure.

## Cost Breakdown by Module

### Default Configuration (RDS Disabled, NAT Gateway Disabled)

| Module | Service | Configuration | Monthly Cost |
|--------|---------|---------------|--------------|
| Networking | VPC, Subnets, IGW, Security Groups | Free tier | $0.00 |
| Security | IAM Roles/Policies | Free | $0.00 |
| Security | KMS Key | Free (pay per API call) | $0.00 |
| Security | Secrets Manager | 2 secrets × $0.40 | $0.80 |
| Storage | S3 Buckets | Free tier (5GB) | $0.00 |
| Storage | EBS gp3 Volume | 8GB × $0.088/GB | $0.70 |
| Compute | Lambda Functions | Free tier (1M requests) | $0.00 |
| Compute | EC2 t2.micro | 730 hours × $0.0116/hour | $8.47 |
| Database | DynamoDB Tables | Free tier (25GB, 25 RCU/WCU) | $0.00 |
| Messaging | SNS Topics | Free tier (1M requests) | $0.00 |
| Messaging | SQS Queues | Free tier (1M requests) | $0.00 |
| Monitoring | CloudWatch Logs | Free tier (5GB ingestion) | $0.00 |
| Monitoring | CloudWatch Alarms | 2 alarms × $0.10 | $0.20 |
| Monitoring | CloudTrail | S3 storage ~1GB | $0.02 |
| API | API Gateway | Free tier (1M requests) | $0.00 |
| Container | ECR Repository | 1GB storage × $0.10/GB | $0.10 |
| Container | ECS Fargate | Minimal usage estimate | $5.00 |
| Code Services | CodeCommit | Free tier (5 users, 50GB) | $0.00 |
| Code Services | CodeBuild | Free tier (100 build minutes) | $0.00 |
| Orchestration | Step Functions | Free tier (4,000 transitions) | $0.00 |
| Orchestration | EventBridge | Free for AWS service events | $0.00 |
| **TOTAL** | | | **~$15.29/month** |

### With Optional Services Enabled

| Optional Service | Additional Cost | Total Cost |
|-----------------|-----------------|------------|
| + RDS db.t3.micro | $12.41 (instance) + $2.30 (storage) | **~$30.00/month** |
| + NAT Gateway (2 AZs) | $32.40 × 2 = $64.80 | **~$80.09/month** |
| + CodePipeline | $1.00 per active pipeline | **~$16.29/month** |
| + All Optional | $14.71 + $64.80 + $1.00 | **~$95.80/month** |

## Cost Optimization Tips

### 1. Disable Expensive Services

```hcl
# In terraform.tfvars
enable_rds         = false  # Saves $14.71/month
enable_nat_gateway = false  # Saves $64.80/month
enable_codepipeline = false # Saves $1.00/month
```

### 2. Reduce ECS Usage

The ECS Fargate service runs continuously. To reduce costs:
- Set desired_count to 0 when not testing
- Use spot capacity for non-critical workloads
- Schedule ECS service to run only during business hours

### 3. Optimize EC2 Usage

```hcl
# Stop EC2 instance when not in use
aws ec2 stop-instances --instance-ids <instance-id>

# Or use Auto Scaling to scale to 0
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name <asg-name> \
  --desired-capacity 0
```

### 4. Clean Up Unused Resources

```bash
# Destroy entire infrastructure when not needed
terraform destroy

# Or disable specific modules
# Set enable_<module> = false in terraform.tfvars
```

## Monitoring Actual Costs

### Using AWS Cost Explorer

```bash
# Get current month costs
aws ce get-cost-and-usage \
  --time-period Start=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=TAG,Key=Project \
  --filter file://cost-filter.json

# cost-filter.json
{
  "Tags": {
    "Key": "Project",
    "Values": ["infrasyn-test"]
  }
}
```

### Using AWS Budgets

1. Go to AWS Budgets in the console
2. Create a new budget:
   - Budget type: Cost budget
   - Budget amount: $100
   - Budget period: Monthly
3. Set up alerts:
   - Alert at 50% ($50)
   - Alert at 80% ($80)
   - Alert at 100% ($100)
4. Add email notifications

### Using the Helper Script

```bash
# Check actual costs
./scripts/check-costs.sh
```

## Free Tier Limits

### Always Free (12 months for new accounts)

- **Lambda**: 1M requests/month, 400,000 GB-seconds compute
- **S3**: 5GB standard storage, 20,000 GET requests, 2,000 PUT requests
- **DynamoDB**: 25GB storage, 25 RCU, 25 WCU
- **CloudWatch**: 10 custom metrics, 10 alarms, 5GB log ingestion
- **SNS**: 1M publishes
- **SQS**: 1M requests
- **API Gateway**: 1M API calls
- **CodeCommit**: 5 active users, 50GB storage, 10,000 requests
- **CodeBuild**: 100 build minutes
- **Step Functions**: 4,000 state transitions

### Always Free (permanent)

- **IAM**: Unlimited users, groups, roles, policies
- **VPC**: 1 VPC per region, subnets, route tables, security groups
- **CloudFormation**: 1,000 handler operations
- **EventBridge**: AWS service events

## Cost Alerts

The infrastructure includes cost validation that prevents deployment if estimated costs exceed the configured limit:

```hcl
# In terraform.tfvars
cost_limit = 100  # Maximum monthly cost in USD
```

If you try to deploy with costs exceeding this limit, Terraform will fail with a detailed cost breakdown and suggestions for reducing costs.

## Regional Pricing Differences

Costs shown are for **ap-south-1 (Mumbai)** region. Prices may vary by region:

- **us-east-1**: Generally 10-15% cheaper
- **eu-west-1**: Similar to us-east-1
- **ap-southeast-1**: Similar to ap-south-1
- **sa-east-1**: Generally 20-30% more expensive

## Additional Costs to Consider

### Data Transfer

- **Outbound data transfer**: $0.109/GB after first 100GB/month (free tier)
- **Inter-AZ data transfer**: $0.01/GB
- **NAT Gateway data processing**: $0.045/GB

### API Calls

- **KMS**: $0.03 per 10,000 requests
- **Secrets Manager**: $0.05 per 10,000 API calls
- **S3**: $0.005 per 1,000 PUT requests (after free tier)

### Storage

- **S3 Standard**: $0.023/GB-month (after free tier)
- **EBS Snapshots**: $0.05/GB-month
- **CloudWatch Logs**: $0.50/GB ingested (after free tier)

## Cost Tracking Best Practices

1. **Tag all resources** with Project, Environment, CostCenter tags
2. **Enable Cost Allocation Tags** in AWS Billing console
3. **Set up AWS Budgets** with email alerts
4. **Review Cost Explorer** weekly
5. **Use AWS Cost Anomaly Detection** for unexpected spikes
6. **Destroy resources** when not actively testing

## Estimated vs Actual Costs

Estimated costs assume:
- Minimal usage within free tier limits
- EC2 and ECS running 24/7
- No data transfer costs
- No API call costs beyond free tier

Actual costs may vary based on:
- Actual usage patterns
- Data transfer volumes
- API call frequency
- Storage growth over time

Always monitor actual costs using AWS Cost Explorer and set up budget alerts!
