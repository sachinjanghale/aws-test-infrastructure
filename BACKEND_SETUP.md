# Terraform Backend Setup

This document explains how to set up the S3 backend for Terraform state management.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Permissions to create S3 buckets and DynamoDB tables

## Option 1: Manual Setup

### Step 1: Create S3 Bucket for State Storage

```bash
aws s3api create-bucket \
  --bucket infrasyn-terraform-state-$(aws sts get-caller-identity --query Account --output text) \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket infrasyn-terraform-state-$(aws sts get-caller-identity --query Account --output text) \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket infrasyn-terraform-state-$(aws sts get-caller-identity --query Account --output text) \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Block public access
aws s3api put-public-access-block \
  --bucket infrasyn-terraform-state-$(aws sts get-caller-identity --query Account --output text) \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

### Step 2: Create DynamoDB Table for State Locking

```bash
aws dynamodb create-table \
  --table-name infrasyn-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1
```

### Step 3: Update versions.tf

Uncomment the backend configuration in `versions.tf` and update the bucket name:

```hcl
backend "s3" {
  bucket         = "infrasyn-terraform-state-<YOUR-ACCOUNT-ID>"
  key            = "test-infrastructure/terraform.tfstate"
  region         = "ap-south-1"
  dynamodb_table = "infrasyn-terraform-locks"
  encrypt        = true
}
```

### Step 4: Initialize Terraform

```bash
terraform init
```

## Option 2: Use Local Backend (Not Recommended for Production)

If you want to use local state storage for testing:

1. Keep the backend configuration commented out in `versions.tf`
2. Run `terraform init`
3. State will be stored in `terraform.tfstate` file locally

**Warning**: Local state is not recommended for team environments or production use.

## Migrating from Local to Remote Backend

If you started with local backend and want to migrate:

1. Set up S3 bucket and DynamoDB table as described above
2. Uncomment backend configuration in `versions.tf`
3. Run `terraform init -migrate-state`
4. Confirm the migration when prompted

## Backend Costs

- S3 storage: ~$0.023 per GB/month (state files are typically < 1MB)
- DynamoDB: Pay-per-request pricing (minimal cost for state locking)
- Total estimated cost: < $0.10/month

## Troubleshooting

### Error: "bucket does not exist"
- Verify the bucket name includes your AWS account ID
- Check that the bucket was created in the correct region

### Error: "table does not exist"
- Verify the DynamoDB table was created successfully
- Check the table name matches the backend configuration

### Error: "Access Denied"
- Ensure your AWS credentials have permissions for S3 and DynamoDB
- Required permissions: s3:GetObject, s3:PutObject, dynamodb:GetItem, dynamodb:PutItem, dynamodb:DeleteItem
