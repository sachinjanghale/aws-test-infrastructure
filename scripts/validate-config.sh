#!/bin/bash
# Configuration Validation Script
# This script validates the Terraform configuration before applying

set -e

echo "=== Terraform Configuration Validation ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}ERROR: Terraform is not installed${NC}"
    echo "Please install Terraform 1.12.0 or later"
    exit 1
fi

echo -e "${GREEN}✓${NC} Terraform is installed"

# Check Terraform version
TF_VERSION=$(terraform version -json | grep -o '"terraform_version":"[^"]*' | cut -d'"' -f4)
echo "  Version: $TF_VERSION"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${YELLOW}WARNING: AWS CLI is not installed${NC}"
    echo "  AWS CLI is recommended for cost checking and troubleshooting"
else
    echo -e "${GREEN}✓${NC} AWS CLI is installed"
    AWS_VERSION=$(aws --version 2>&1 | cut -d' ' -f1 | cut -d'/' -f2)
    echo "  Version: $AWS_VERSION"
fi

# Check AWS credentials
echo ""
echo "Checking AWS credentials..."
if aws sts get-caller-identity &> /dev/null; then
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    USER_ARN=$(aws sts get-caller-identity --query Arn --output text)
    echo -e "${GREEN}✓${NC} AWS credentials are configured"
    echo "  Account: $ACCOUNT_ID"
    echo "  Identity: $USER_ARN"
else
    echo -e "${RED}ERROR: AWS credentials are not configured${NC}"
    echo "Please configure AWS credentials using 'aws configure'"
    exit 1
fi

# Check if terraform.tfvars exists
echo ""
echo "Checking configuration files..."
if [ ! -f "terraform.tfvars" ]; then
    echo -e "${YELLOW}WARNING: terraform.tfvars not found${NC}"
    echo "  Copy terraform.tfvars.example to terraform.tfvars and customize"
    echo "  cp terraform.tfvars.example terraform.tfvars"
else
    echo -e "${GREEN}✓${NC} terraform.tfvars exists"
fi

# Initialize Terraform
echo ""
echo "Initializing Terraform..."
if terraform init -upgrade > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Terraform initialized successfully"
else
    echo -e "${RED}ERROR: Terraform initialization failed${NC}"
    terraform init
    exit 1
fi

# Validate Terraform configuration
echo ""
echo "Validating Terraform configuration..."
if terraform validate > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Terraform configuration is valid"
else
    echo -e "${RED}ERROR: Terraform configuration is invalid${NC}"
    terraform validate
    exit 1
fi

# Format check
echo ""
echo "Checking Terraform formatting..."
if terraform fmt -check -recursive > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Terraform files are properly formatted"
else
    echo -e "${YELLOW}WARNING: Some Terraform files need formatting${NC}"
    echo "  Run 'terraform fmt -recursive' to fix"
fi

# Run terraform plan
echo ""
echo "Running Terraform plan..."
echo "This may take a few minutes..."
if terraform plan -out=tfplan > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Terraform plan completed successfully"
    
    # Show resource summary
    echo ""
    echo "=== Resource Summary ==="
    terraform show -json tfplan | jq -r '.resource_changes[] | .type' | sort | uniq -c | sort -rn
    
    # Show estimated cost
    echo ""
    echo "=== Cost Estimate ==="
    terraform plan -out=tfplan 2>&1 | grep -A 20 "estimated_monthly_cost" || echo "Cost information not available in plan output"
    
    rm -f tfplan
else
    echo -e "${RED}ERROR: Terraform plan failed${NC}"
    terraform plan
    exit 1
fi

# Check for common issues
echo ""
echo "=== Configuration Checks ==="

# Check if expensive services are enabled
if grep -q "enable_rds.*=.*true" terraform.tfvars 2>/dev/null; then
    echo -e "${YELLOW}⚠${NC}  RDS is enabled (+$15/month)"
fi

if grep -q "enable_nat_gateway.*=.*true" terraform.tfvars 2>/dev/null; then
    echo -e "${YELLOW}⚠${NC}  NAT Gateway is enabled (+$65/month)"
fi

if grep -q "enable_codepipeline.*=.*true" terraform.tfvars 2>/dev/null; then
    echo -e "${YELLOW}⚠${NC}  CodePipeline is enabled (+$1/month)"
fi

# Check region
REGION=$(grep "aws_region" terraform.tfvars 2>/dev/null | cut -d'=' -f2 | tr -d ' "' || echo "ap-south-1")
echo -e "${GREEN}✓${NC} Region: $REGION"

# Check project name
PROJECT=$(grep "project_name" terraform.tfvars 2>/dev/null | cut -d'=' -f2 | tr -d ' "' || echo "infrasyn-test")
echo -e "${GREEN}✓${NC} Project: $PROJECT"

echo ""
echo "=== Validation Complete ==="
echo ""
echo -e "${GREEN}All checks passed!${NC}"
echo ""
echo "Next steps:"
echo "  1. Review the plan output above"
echo "  2. Run 'terraform apply' to create the infrastructure"
echo "  3. Run 'terraform destroy' when done to avoid charges"
echo ""
