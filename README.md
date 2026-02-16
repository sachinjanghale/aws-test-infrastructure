# AWS Test Infrastructure

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-1.12+-purple.svg)](https://www.terraform.io/)
[![AWS Provider](https://img.shields.io/badge/AWS%20Provider-5.98.0-orange.svg)](https://registry.terraform.io/providers/hashicorp/aws/latest)
[![GitHub stars](https://img.shields.io/github/stars/sachinjanghale/aws-test-infrastructure?style=social)](https://github.com/sachinjanghale/aws-test-infrastructure/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/sachinjanghale/aws-test-infrastructure?style=social)](https://github.com/sachinjanghale/aws-test-infrastructure/network/members)
[![GitHub issues](https://img.shields.io/github/issues/sachinjanghale/aws-test-infrastructure)](https://github.com/sachinjanghale/aws-test-infrastructure/issues)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/sachinjanghale/aws-test-infrastructure/pulls)

A comprehensive Terraform project that provisions a diverse AWS test infrastructure for testing cloud migration tools, IaC generators, and AWS service discovery tools. This project creates 145+ AWS resources across 28 service categories while staying within free tier or minimal cost.

## 🎯 Purpose

This infrastructure is designed to:
- Test AWS-to-IaC migration tools (like [infrasyn.app](https://infrasyn.app))
- Validate cloud discovery and inventory tools
- Provide a realistic multi-service AWS environment for testing
- Demonstrate Terraform best practices and patterns
- Serve as a learning resource for AWS and Terraform

## Overview

The infrastructure includes:
- **Networking**: VPC, subnets, security groups, internet gateway
- **Security**: IAM roles/policies, KMS keys, Secrets Manager
- **Storage**: S3 buckets, EBS volumes
- **Compute**: Lambda functions, EC2 instances, Auto Scaling
- **Database**: DynamoDB tables, optional RDS instance
- **Messaging**: SNS topics, SQS queues
- **Monitoring**: CloudWatch logs/alarms/dashboards, CloudTrail
- **API**: API Gateway REST APIs
- **Container**: ECR repositories, ECS clusters/services
- **Code Services**: CodeCommit, CodeBuild, optional CodePipeline
- **Orchestration**: Step Functions, EventBridge

## Cost Estimate

With default settings (RDS disabled):
- **Total**: ~$17/month
- Breakdown: Compute ($8) + Container ($5) + Monitoring ($2) + Security ($1) + Storage ($1)

With RDS enabled: ~$32/month

All estimates assume minimal usage within free tier limits where applicable.

## Prerequisites

1. **AWS Account** with free tier eligibility or credits
2. **AWS CLI** configured with credentials
3. **Terraform** >= 1.5.0
4. **Permissions**: Administrator access or equivalent IAM permissions

## Quick Start

### 1. Clone and Configure

```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your settings
# At minimum, review and adjust:
# - aws_region (default: ap-south-1)
# - project_name
# - enable_* flags for modules you want to provision
```

### 2. Set Up Backend (Recommended)

See [BACKEND_SETUP.md](BACKEND_SETUP.md) for detailed instructions on setting up S3 backend for state management.

For quick local testing, you can skip this step (not recommended for production).

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review Plan

```bash
terraform plan
```

Review the planned resources and estimated costs.

### 5. Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted to confirm.

## Configuration Options

### Module Flags

Enable or disable specific service categories:

```hcl
enable_networking    = true  # VPC, subnets, security groups
enable_security      = true  # IAM, KMS, Secrets Manager
enable_storage       = true  # S3, EBS
enable_compute       = true  # Lambda, EC2, Auto Scaling
enable_database      = true  # DynamoDB, optional RDS
enable_messaging     = true  # SNS, SQS
enable_monitoring    = true  # CloudWatch, CloudTrail
enable_api           = true  # API Gateway
enable_container     = true  # ECR, ECS
enable_code_services = true  # CodeCommit, CodeBuild
enable_orchestration = true  # Step Functions, EventBridge
```

### Cost-Sensitive Options

```hcl
enable_rds         = false # Adds ~$15/month
enable_nat_gateway = false # Adds ~$32/month per AZ
enable_codepipeline = false # Minimal cost but adds complexity
```

### Region Configuration

```hcl
aws_region = "ap-south-1" # Mumbai region (default)
```

## Project Structure

```
.
├── main.tf                 # Root configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── versions.tf             # Provider versions and backend config
├── cost_estimation.tf      # Cost calculation logic (to be added)
├── terraform.tfvars.example # Example configuration
├── modules/                # Terraform modules
│   ├── networking/
│   ├── security/
│   ├── storage/
│   ├── compute/
│   ├── database/
│   ├── messaging/
│   ├── monitoring/
│   ├── api/
│   ├── container/
│   ├── code_services/
│   └── orchestration/
└── README.md
```

## Usage

### Provision Infrastructure

```bash
terraform apply
```

### View Outputs

```bash
terraform output
```

### Destroy Infrastructure

```bash
terraform destroy
```

**Important**: Always destroy resources when done testing to avoid unnecessary costs.

## SSH Access to EC2 Instances

The infrastructure automatically creates an SSH key pair for EC2 access:

- **Key Pair Name**: `{project_name}-ec2-key`
- **Private Key File**: `{project_name}-ec2-key.pem` (created in project root)
- **File Permissions**: Automatically set to 0400

### Connecting to EC2

```bash
# Get EC2 public IP
EC2_IP=$(terraform output -raw ec2_instance_public_ip)

# Connect via SSH
ssh -i aws-test-infra-ec2-key.pem ec2-user@$EC2_IP
```

**Note**: The private key file is automatically added to .gitignore to prevent accidental commits.

## IAM Edge Cases

The infrastructure includes several IAM edge cases for comprehensive testing:

### EC2 S3 Full Access
The EC2 instance has TWO separate IAM policies for S3 access:
1. **Limited access** (via inline policy): GetObject, PutObject, ListBucket on all project buckets
2. **Full access** (via separate policy): s3:* on the encrypted bucket only

This mimics real-world scenarios where instances have both general and specific permissions.

### IAM Users and Groups
- 2 IAM users created: `test-user1` and `test-user2`
- 1 IAM group: `developers` with ReadOnlyAccess
- Both users are members of the group
- `test-user1` has additional inline policy for DynamoDB access
- `test-user2` has attached custom policy for CloudWatch Logs
- `test-user1` has an access key created (for API access testing)

## Monitoring Costs

### Using AWS Cost Explorer

```bash
# Get current month costs
aws ce get-cost-and-usage \
  --time-period Start=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=TAG,Key=Project
```

### Using AWS Budgets

Set up a budget alert in AWS Console:
1. Go to AWS Budgets
2. Create a budget with $100 limit
3. Set alert threshold at 80% ($80)
4. Add your email for notifications

## Testing with infrasyn.app

After provisioning:

1. Configure infrasyn.app with your AWS credentials
2. Run scan against the test account
3. Verify that all provisioned resources are detected
4. Check that generated Terraform code matches the original configuration
5. Test import of tfstate

## Troubleshooting

### Error: "Insufficient permissions"
- Ensure your AWS credentials have necessary permissions
- Check IAM policies attached to your user/role

### Error: "Resource already exists"
- Resource names may conflict with existing resources
- Change `project_name` variable to use a unique identifier

### Error: "Cost limit exceeded"
- Review enabled modules in terraform.tfvars
- Disable expensive modules (RDS, NAT Gateway)
- Adjust `cost_limit` variable if needed

### State Lock Errors
- Ensure DynamoDB table exists for state locking
- Check that no other Terraform process is running
- If stuck, manually release lock in DynamoDB console

## Security Best Practices

1. **Never commit terraform.tfvars** - Contains sensitive configuration
2. **Use backend encryption** - Enable encryption for S3 state bucket
3. **Rotate credentials** - Regularly rotate AWS access keys
4. **Review IAM policies** - Ensure least privilege access
5. **Enable MFA** - Use MFA for AWS account access

## Contributing

We welcome contributions! This project is open source and community-driven.

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly (`terraform validate`, `terraform plan`)
5. Commit your changes (`git commit -m 'Add: amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

### Areas for Contribution

- Add support for more AWS services
- Improve cost optimization
- Enhance documentation
- Add testing scripts
- Report bugs and issues

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Community

- **Issues**: Report bugs or request features via [GitHub Issues](../../issues)
- **Discussions**: Join conversations in [GitHub Discussions](../../discussions)
- **Pull Requests**: Contribute code via [Pull Requests](../../pulls)

## 📚 Documentation

- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) - Community standards
- [EDGE_CASES.md](EDGE_CASES.md) - Special configurations and edge cases
- [BACKEND_SETUP.md](BACKEND_SETUP.md) - S3 backend configuration
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues and solutions
- [COST_ESTIMATION.md](COST_ESTIMATION.md) - Detailed cost breakdown
- [IAM_PERMISSIONS.md](IAM_PERMISSIONS.md) - Required IAM permissions

## ⭐ Star History

If you find this project useful, please consider giving it a star! It helps others discover the project.

## 🙏 Acknowledgments

- Built for testing [infrasyn.app](https://infrasyn.app) - AWS to IaC migration tool
- Inspired by real-world AWS architectures
- Community contributions and feedback

## 📞 Support

For issues related to:
- **This project**: Open a [GitHub Issue](../../issues)
- **Terraform**: Check [Terraform documentation](https://www.terraform.io/docs)
- **AWS services**: Refer to [AWS documentation](https://docs.aws.amazon.com/)
- **infrasyn.app**: Contact [infrasyn.app support](https://infrasyn.app)

---

**Made with ❤️ for the cloud infrastructure community**
