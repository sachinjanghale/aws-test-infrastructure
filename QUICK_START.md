# Quick Start Guide

Get your AWS test infrastructure up and running in 5 minutes!

## Prerequisites Checklist

- [ ] AWS Account (free tier eligible)
- [ ] AWS CLI installed and configured
- [ ] Terraform >= 1.12.0 installed
- [ ] 10-15 minutes of time

## 5-Minute Setup

### 1. Clone Repository (30 seconds)

```bash
git clone https://github.com/sachinjanghale/aws-test-infrastructure.git
cd aws-test-infrastructure
```

### 2. Configure Variables (2 minutes)

```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your settings
nano terraform.tfvars  # or use your favorite editor
```

**Minimal required changes:**
```hcl
project_name = "my-test-infra"  # Change to your unique name
aws_region   = "us-east-1"      # Change to your preferred region
```

### 3. Initialize Terraform (1 minute)

```bash
terraform init
```

### 4. Review Plan (1 minute)

```bash
terraform plan
```

Review the resources that will be created and estimated costs.

### 5. Deploy Infrastructure (5-10 minutes)

```bash
terraform apply
```

Type `yes` when prompted.

## What Gets Created?

With default settings:
- ✅ 1 VPC with 4 subnets
- ✅ 4 Security groups
- ✅ 2 Lambda functions
- ✅ 1 EC2 instance (t2.micro)
- ✅ 2 S3 buckets
- ✅ 2 DynamoDB tables
- ✅ 1 API Gateway
- ✅ 1 ECS cluster
- ✅ CloudWatch monitoring
- ✅ And much more!

**Total: 145+ resources**

## Cost Estimate

- **Minimum**: ~$17/month (RDS disabled)
- **Default**: ~$37/month (RDS enabled)
- **Maximum**: ~$100/month (all features enabled)

## Quick Commands

### View Outputs
```bash
terraform output
```

### Get EC2 IP
```bash
terraform output ec2_instance_public_ip
```

### SSH to EC2
```bash
ssh -i aws-test-infra-ec2-key.pem ec2-user@$(terraform output -raw ec2_instance_public_ip)
```

### Check Costs
```bash
./scripts/check-costs.sh
```

### Destroy Everything
```bash
terraform destroy
```

## Common Customizations

### Disable Expensive Services

Edit `terraform.tfvars`:
```hcl
enable_rds = false          # Saves ~$15/month
enable_nat_gateway = false  # Saves ~$32/month
```

### Change Region

```hcl
aws_region = "eu-west-1"  # Change to any AWS region
```

### Enable/Disable Modules

```hcl
enable_compute = true   # Lambda, EC2, Auto Scaling
enable_database = true  # DynamoDB, RDS
enable_container = true # ECR, ECS
# ... and more
```

## Troubleshooting

### Error: "Insufficient permissions"
→ Check your AWS credentials have admin access

### Error: "Resource already exists"
→ Change `project_name` to something unique

### Error: "Cost limit exceeded"
→ Disable expensive modules in terraform.tfvars

### Need Help?
- 📖 Read [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- 🐛 Open an [Issue](../../issues)
- 💬 Start a [Discussion](../../discussions)

## Next Steps

After deployment:

1. **Explore Resources**
   ```bash
   # List all resources
   terraform state list
   
   # View specific resource
   terraform state show aws_instance.web
   ```

2. **Test API Gateway**
   ```bash
   API_URL=$(terraform output -raw api_gateway_endpoint)
   curl $API_URL/hello
   ```

3. **View CloudWatch Dashboard**
   - Go to AWS Console → CloudWatch → Dashboards
   - Open `aws-test-infra-dashboard`

4. **Check S3 Buckets**
   ```bash
   aws s3 ls | grep aws-test-infra
   ```

5. **Test with Migration Tool**
   - Point your migration tool to this AWS account
   - Verify all resources are detected
   - Compare generated IaC with original

## Clean Up

**Important**: Always destroy resources when done testing!

```bash
# Destroy all resources
terraform destroy

# Verify nothing remains
aws resourcegroupstaggingapi get-resources \
  --tag-filters Key=Project,Values=aws-test-infra
```

## Tips for Success

1. **Start Small**: Enable only a few modules first
2. **Monitor Costs**: Check AWS Cost Explorer daily
3. **Use Free Tier**: Most services have free tier limits
4. **Set Budgets**: Create AWS Budget alerts
5. **Clean Up**: Destroy resources when not in use

## Getting Help

- 📚 [Full Documentation](README.md)
- 🔧 [Troubleshooting Guide](TROUBLESHOOTING.md)
- 💰 [Cost Breakdown](COST_ESTIMATION.md)
- 🔐 [IAM Permissions](IAM_PERMISSIONS.md)
- 🎯 [Edge Cases](EDGE_CASES.md)

## Contributing

Found a bug? Want to add a feature?
- 🐛 [Report Issues](../../issues)
- 🔀 [Submit PRs](../../pulls)
- 📖 [Read Contributing Guide](CONTRIBUTING.md)

---

**Ready to deploy? Run `terraform apply` and you're good to go! 🚀**
