# Troubleshooting Guide

This guide helps resolve common issues when deploying the AWS test infrastructure.

## Table of Contents

- [Terraform Errors](#terraform-errors)
- [AWS Permission Errors](#aws-permission-errors)
- [Resource Creation Failures](#resource-creation-failures)
- [State Management Issues](#state-management-issues)
- [Cost Limit Errors](#cost-limit-errors)
- [Module Dependency Errors](#module-dependency-errors)
- [Network Connectivity Issues](#network-connectivity-issues)

## Terraform Errors

### Error: "terraform: command not found"

**Cause**: Terraform is not installed or not in PATH

**Solution**:
```bash
# Install Terraform (Linux/macOS)
wget https://releases.hashicorp.com/terraform/1.12.0/terraform_1.12.0_linux_amd64.zip
unzip terraform_1.12.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Verify installation
terraform version
```

### Error: "Required version constraint not satisfied"

**Cause**: Terraform version is too old

**Solution**:
```bash
# Check current version
terraform version

# Upgrade to 1.12.0 or later
# Follow installation steps above
```

### Error: "Error loading state: NoSuchBucket"

**Cause**: S3 backend bucket doesn't exist

**Solution**:
```bash
# Create the backend bucket
aws s3api create-bucket \
  --bucket infrasyn-terraform-state-$(aws sts get-caller-identity --query Account --output text) \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket infrasyn-terraform-state-$(aws sts get-caller-identity --query Account --output text) \
  --versioning-configuration Status=Enabled
```

## AWS Permission Errors

### Error: "AccessDenied" or "UnauthorizedOperation"

**Cause**: AWS credentials lack necessary permissions

**Solution**:

1. Verify AWS credentials are configured:
```bash
aws sts get-caller-identity
```

2. Ensure IAM user/role has required permissions:
   - EC2: Full access or specific permissions for VPC, instances, security groups
   - IAM: Create/manage roles and policies
   - S3: Create/manage buckets
   - Lambda: Create/manage functions
   - RDS: Create/manage instances (if enabled)
   - And permissions for all other enabled services

3. Attach the following managed policies (for testing only):
   - `PowerUserAccess` (recommended for testing)
   - Or create custom policy with specific permissions

### Error: "You are not authorized to perform this operation"

**Cause**: Missing specific IAM permissions

**Solution**:

Check CloudTrail logs to see which specific permission is missing:
```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=<FailedOperation> \
  --max-results 1
```

Add the missing permission to your IAM policy.

## Resource Creation Failures

### Error: "InvalidParameterValue: Security group ... does not exist"

**Cause**: Networking module is disabled but compute module is enabled

**Solution**:
```hcl
# In terraform.tfvars
enable_networking = true  # Required for compute, database, container modules
enable_compute    = true
```

### Error: "InvalidParameterValue: Role ... does not exist"

**Cause**: Security module is disabled but dependent modules are enabled

**Solution**:
```hcl
# In terraform.tfvars
enable_security = true  # Required for most modules
```

### Error: "BucketAlreadyExists" or "BucketAlreadyOwnedByYou"

**Cause**: S3 bucket name conflict

**Solution**:

S3 bucket names must be globally unique. Change the project name:
```hcl
# In terraform.tfvars
project_name = "infrasyn-test-unique-suffix"
```

Or manually delete the existing bucket:
```bash
aws s3 rb s3://<bucket-name> --force
```

### Error: "InvalidAMIID.NotFound"

**Cause**: AMI not available in the selected region

**Solution**:

The code uses data source to find the latest Amazon Linux 2023 AMI. If this fails:
1. Verify the region is correct
2. Check AWS service health dashboard
3. Try a different region

### Error: "Unsupported availability zone"

**Cause**: Selected AZ doesn't support required services

**Solution**:
```hcl
# In terraform.tfvars, specify different AZs
availability_zones = ["ap-south-1a", "ap-south-1b"]
```

## State Management Issues

### Error: "Error acquiring the state lock"

**Cause**: Another Terraform process is running or previous run didn't release lock

**Solution**:

1. Wait for other Terraform process to complete
2. If stuck, manually release the lock:
```bash
# Get lock ID from error message
terraform force-unlock <LOCK_ID>
```

3. If using DynamoDB locking, check the locks table:
```bash
aws dynamodb scan --table-name infrasyn-terraform-locks
```

### Error: "State file is corrupt"

**Cause**: State file was manually edited or corrupted

**Solution**:

1. Restore from S3 versioning:
```bash
aws s3api list-object-versions \
  --bucket <state-bucket> \
  --prefix test-infrastructure/terraform.tfstate

# Restore previous version
aws s3api get-object \
  --bucket <state-bucket> \
  --key test-infrastructure/terraform.tfstate \
  --version-id <VERSION_ID> \
  terraform.tfstate
```

2. If no backup, you may need to import resources manually:
```bash
terraform import <resource_type>.<resource_name> <resource_id>
```

## Cost Limit Errors

### Error: "Cost limit exceeded!"

**Cause**: Estimated costs exceed configured budget

**Solution**:

1. Review the cost breakdown in the error message
2. Disable expensive modules:
```hcl
# In terraform.tfvars
enable_rds         = false  # Saves ~$15/month
enable_nat_gateway = false  # Saves ~$65/month
enable_container   = false  # Saves ~$5/month
```

3. Or increase the cost limit (if you have budget):
```hcl
# In terraform.tfvars
cost_limit = 150  # Increase from default 100
```

## Module Dependency Errors

### Error: "The module ... has no output named ..."

**Cause**: Trying to access output from disabled module

**Solution**:

Enable the required module:
```hcl
# Example: API module requires compute module
enable_compute = true
enable_api     = true
```

### Error: "Invalid index" or "element() may not be used with an empty list"

**Cause**: Module dependency not met

**Solution**:

Check module dependencies in main.tf and enable required modules:
- Compute requires: networking, security
- Database requires: networking (for RDS), security
- Container requires: networking, security
- API requires: compute
- Monitoring requires: compute (optional), messaging (optional)
- Orchestration requires: compute, security

## Network Connectivity Issues

### Error: "Connection timeout" when accessing EC2 instance

**Cause**: Security group rules or network configuration

**Solution**:

1. Verify security group allows SSH (port 22):
```bash
aws ec2 describe-security-groups \
  --group-ids <security-group-id>
```

2. Ensure instance has public IP:
```bash
aws ec2 describe-instances \
  --instance-ids <instance-id> \
  --query 'Reservations[0].Instances[0].PublicIpAddress'
```

3. Check route table has route to Internet Gateway

### Error: "Unable to connect to RDS instance"

**Cause**: RDS is in private subnet without NAT Gateway

**Solution**:

1. Enable NAT Gateway (adds cost):
```hcl
enable_nat_gateway = true
```

2. Or connect from EC2 instance in same VPC
3. Or use VPN/Direct Connect

### Error: "ECS task failed to start"

**Cause**: Multiple possible causes

**Solution**:

1. Check ECS task logs:
```bash
aws logs tail /ecs/infrasyn-test --follow
```

2. Verify ECR image exists (or using public nginx image)
3. Check IAM role permissions
4. Verify security group allows required ports

## Lambda Function Errors

### Error: "Lambda function failed to execute"

**Cause**: Code error, timeout, or permission issue

**Solution**:

1. Check CloudWatch Logs:
```bash
aws logs tail /aws/lambda/<function-name> --follow
```

2. Verify IAM role has required permissions
3. Increase timeout if needed (default is 30 seconds)
4. Check environment variables are set correctly

## API Gateway Errors

### Error: "Missing Authentication Token"

**Cause**: Incorrect API endpoint or path

**Solution**:

1. Get correct API endpoint:
```bash
terraform output api_gateway_endpoint
```

2. Verify path exists:
   - GET /hello
   - POST /data

3. Test with curl:
```bash
curl https://<api-id>.execute-api.ap-south-1.amazonaws.com/dev/hello
```

## Getting Help

If you encounter an issue not covered here:

1. **Check Terraform logs**:
```bash
TF_LOG=DEBUG terraform apply
```

2. **Check AWS CloudTrail** for API errors:
```bash
aws cloudtrail lookup-events --max-results 10
```

3. **Review AWS service quotas**:
```bash
aws service-quotas list-service-quotas --service-code <service>
```

4. **Check AWS Service Health Dashboard**:
   https://status.aws.amazon.com/

5. **Consult AWS documentation** for specific services

6. **Contact AWS Support** if you have a support plan
