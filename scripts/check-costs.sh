#!/bin/bash
# Cost Checking Script
# This script checks actual AWS costs for the infrastructure

set -e

echo "=== AWS Cost Checker ==="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}ERROR: AWS CLI is not installed${NC}"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}WARNING: jq is not installed${NC}"
    echo "Install jq for better output formatting: sudo apt-get install jq"
    JQ_AVAILABLE=false
else
    JQ_AVAILABLE=true
fi

# Get project name from terraform.tfvars
PROJECT_NAME=$(grep "project_name" terraform.tfvars 2>/dev/null | cut -d'=' -f2 | tr -d ' "' || echo "infrasyn-test")

# Get current month dates
START_DATE=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d)
END_DATE=$(date +%Y-%m-%d)

echo "Project: $PROJECT_NAME"
echo "Period: $START_DATE to $END_DATE"
echo ""

# Get costs for current month
echo "Fetching cost data from AWS Cost Explorer..."
echo ""

COST_DATA=$(aws ce get-cost-and-usage \
    --time-period Start=$START_DATE,End=$END_DATE \
    --granularity MONTHLY \
    --metrics BlendedCost UnblendedCost \
    --group-by Type=SERVICE \
    2>/dev/null)

if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Failed to fetch cost data${NC}"
    echo "Make sure you have permissions for Cost Explorer API"
    exit 1
fi

# Parse and display costs
if [ "$JQ_AVAILABLE" = true ]; then
    echo "=== Costs by Service ==="
    echo "$COST_DATA" | jq -r '.ResultsByTime[0].Groups[] | "\(.Keys[0]): $\(.Metrics.BlendedCost.Amount | tonumber | . * 100 | round / 100)"' | sort -t'$' -k2 -rn
    
    echo ""
    echo "=== Total Cost ==="
    TOTAL=$(echo "$COST_DATA" | jq -r '.ResultsByTime[0].Total.BlendedCost.Amount | tonumber | . * 100 | round / 100')
    echo -e "${GREEN}$${TOTAL}${NC}"
else
    echo "$COST_DATA"
fi

echo ""

# Get costs by tag (if tagged properly)
echo "=== Costs by Project Tag ==="
TAG_COST=$(aws ce get-cost-and-usage \
    --time-period Start=$START_DATE,End=$END_DATE \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=TAG,Key=Project \
    2>/dev/null)

if [ $? -eq 0 ]; then
    if [ "$JQ_AVAILABLE" = true ]; then
        echo "$TAG_COST" | jq -r '.ResultsByTime[0].Groups[] | "\(.Keys[0]): $\(.Metrics.BlendedCost.Amount | tonumber | . * 100 | round / 100)"'
    else
        echo "$TAG_COST"
    fi
else
    echo "No cost data available by Project tag"
    echo "Make sure resources are tagged with Project=$PROJECT_NAME"
fi

echo ""

# Forecast for end of month
echo "=== Cost Forecast ==="
FORECAST=$(aws ce get-cost-forecast \
    --time-period Start=$END_DATE,End=$(date -d "$(date +%Y-%m-01) +1 month -1 day" +%Y-%m-%d) \
    --metric BLENDED_COST \
    --granularity MONTHLY \
    2>/dev/null)

if [ $? -eq 0 ]; then
    if [ "$JQ_AVAILABLE" = true ]; then
        FORECAST_AMOUNT=$(echo "$FORECAST" | jq -r '.Total.Amount | tonumber | . * 100 | round / 100')
        echo "Forecasted month-end cost: \$$FORECAST_AMOUNT"
    else
        echo "$FORECAST"
    fi
else
    echo "Forecast not available (requires at least 2 weeks of cost data)"
fi

echo ""

# Budget check
COST_LIMIT=$(grep "cost_limit" terraform.tfvars 2>/dev/null | cut -d'=' -f2 | tr -d ' ' || echo "100")
if [ "$JQ_AVAILABLE" = true ] && [ ! -z "$TOTAL" ]; then
    PERCENTAGE=$(echo "scale=1; $TOTAL / $COST_LIMIT * 100" | bc)
    echo "=== Budget Status ==="
    echo "Budget limit: \$$COST_LIMIT"
    echo "Current spend: \$$TOTAL ($PERCENTAGE%)"
    
    if (( $(echo "$TOTAL > $COST_LIMIT" | bc -l) )); then
        echo -e "${RED}⚠ OVER BUDGET!${NC}"
    elif (( $(echo "$TOTAL > $COST_LIMIT * 0.8" | bc -l) )); then
        echo -e "${YELLOW}⚠ Warning: Over 80% of budget${NC}"
    else
        echo -e "${GREEN}✓ Within budget${NC}"
    fi
fi

echo ""
echo "=== Recommendations ==="
echo "1. Review costs by service above"
echo "2. Disable unused modules to reduce costs"
echo "3. Stop EC2 instances when not testing"
echo "4. Set desired_count=0 for ECS service when not needed"
echo "5. Run 'terraform destroy' when done testing"
echo ""
