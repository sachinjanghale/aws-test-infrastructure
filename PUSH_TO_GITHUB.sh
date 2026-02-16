#!/bin/bash

# AWS Test Infrastructure - GitHub Push Script
# This script helps you push your project to GitHub

set -e  # Exit on error

echo "🚀 AWS Test Infrastructure - GitHub Setup"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git is not installed. Please install git first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Git is installed${NC}"

# Check if already a git repository
if [ -d .git ]; then
    echo -e "${YELLOW}⚠️  This is already a git repository${NC}"
    read -p "Do you want to continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "📦 Initializing git repository..."
    git init
    echo -e "${GREEN}✅ Git repository initialized${NC}"
fi

# Check for sensitive files
echo ""
echo "🔍 Checking for sensitive files..."
if [ -f "terraform.tfvars" ]; then
    echo -e "${RED}❌ Found terraform.tfvars - This should NOT be committed!${NC}"
    echo "   Please remove it or ensure it's in .gitignore"
    exit 1
fi

if ls *.pem 1> /dev/null 2>&1; then
    echo -e "${RED}❌ Found .pem files - These should NOT be committed!${NC}"
    echo "   Please remove them or ensure they're in .gitignore"
    exit 1
fi

echo -e "${GREEN}✅ No sensitive files found${NC}"

# Get GitHub username
echo ""
read -p "Enter your GitHub username: " GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo -e "${RED}❌ GitHub username is required${NC}"
    exit 1
fi

# Get repository name
echo ""
read -p "Enter repository name (default: aws-test-infrastructure): " REPO_NAME
REPO_NAME=${REPO_NAME:-aws-test-infrastructure}

# Update documentation with username
echo ""
echo "📝 Updating documentation with your GitHub username..."
find . -type f -name "*.md" -not -path "./.git/*" -exec sed -i.bak "s/YOUR_USERNAME/$GITHUB_USERNAME/g" {} \;
find . -type f -name "*.md.bak" -delete
echo -e "${GREEN}✅ Documentation updated${NC}"

# Add all files
echo ""
echo "📦 Adding files to git..."
git add .
echo -e "${GREEN}✅ Files added${NC}"

# Create initial commit
echo ""
echo "💾 Creating initial commit..."
git commit -m "Initial commit: AWS Test Infrastructure v1.0.0

- 145+ AWS resources across 28 service categories
- Modular Terraform configuration
- Cost-optimized for free tier
- Comprehensive documentation
- SSH key pair generation
- IAM edge cases for testing
- VPC endpoints support
- Route53 integration"

echo -e "${GREEN}✅ Initial commit created${NC}"

# Rename branch to main
echo ""
echo "🔀 Renaming branch to main..."
git branch -M main
echo -e "${GREEN}✅ Branch renamed to main${NC}"

# Check if GitHub CLI is installed
echo ""
if command -v gh &> /dev/null; then
    echo -e "${GREEN}✅ GitHub CLI is installed${NC}"
    echo ""
    read -p "Do you want to create the repository using GitHub CLI? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🔐 Logging in to GitHub..."
        gh auth login
        
        echo ""
        echo "📦 Creating repository on GitHub..."
        gh repo create "$REPO_NAME" \
            --public \
            --source=. \
            --remote=origin \
            --description "Comprehensive AWS test infrastructure with 145+ resources for testing cloud migration tools" \
            --push
        
        echo -e "${GREEN}✅ Repository created and pushed!${NC}"
        
        # Add topics
        echo ""
        echo "🏷️  Adding topics to repository..."
        gh repo edit --add-topic terraform,aws,infrastructure-as-code,cloud,devops,aws-infrastructure,terraform-modules,iac,cloud-migration,aws-services,free-tier,terraform-aws,aws-testing,cloud-testing
        
        echo -e "${GREEN}✅ Topics added${NC}"
        
        # Create release
        echo ""
        read -p "Do you want to create the v1.0.0 release? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git tag -a v1.0.0 -m "Initial release: AWS Test Infrastructure"
            git push origin v1.0.0
            
            gh release create v1.0.0 \
                --title "v1.0.0 - Initial Release" \
                --notes "First public release of AWS Test Infrastructure

## Features
- 145+ AWS resources across 28 service categories
- Modular Terraform configuration
- Cost-optimized for free tier
- Comprehensive documentation
- SSH key pair generation
- IAM edge cases for testing
- VPC endpoints support
- Route53 integration

## Cost
- Default: ~\$37/month
- Minimum: ~\$17/month (RDS disabled)

See [CHANGELOG.md](CHANGELOG.md) for full details."
            
            echo -e "${GREEN}✅ Release v1.0.0 created${NC}"
        fi
        
        echo ""
        echo -e "${GREEN}🎉 All done! Your repository is live at:${NC}"
        echo -e "${GREEN}   https://github.com/$GITHUB_USERNAME/$REPO_NAME${NC}"
        
    else
        echo ""
        echo "📝 Manual setup required. Follow these steps:"
        echo ""
        echo "1. Go to https://github.com/new"
        echo "2. Repository name: $REPO_NAME"
        echo "3. Description: Comprehensive AWS test infrastructure with 145+ resources for testing cloud migration tools"
        echo "4. Make it Public"
        echo "5. DO NOT initialize with README, .gitignore, or license"
        echo "6. Click 'Create repository'"
        echo ""
        echo "Then run these commands:"
        echo ""
        echo "  git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
        echo "  git push -u origin main"
        echo ""
    fi
else
    echo -e "${YELLOW}⚠️  GitHub CLI is not installed${NC}"
    echo ""
    echo "📝 Manual setup required. Follow these steps:"
    echo ""
    echo "1. Go to https://github.com/new"
    echo "2. Repository name: $REPO_NAME"
    echo "3. Description: Comprehensive AWS test infrastructure with 145+ resources for testing cloud migration tools"
    echo "4. Make it Public"
    echo "5. DO NOT initialize with README, .gitignore, or license"
    echo "6. Click 'Create repository'"
    echo ""
    echo "Then run these commands:"
    echo ""
    echo "  git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
    echo "  git push -u origin main"
    echo ""
    echo "To install GitHub CLI: https://cli.github.com/"
    echo ""
fi

echo ""
echo "📚 Next steps:"
echo "  1. Configure repository settings (see GITHUB_SETUP.md)"
echo "  2. Enable GitHub Actions"
echo "  3. Add branch protection rules"
echo "  4. Share your project on social media"
echo "  5. Engage with the community"
echo ""
echo "📖 For detailed instructions, see GITHUB_SETUP.md"
echo ""
echo -e "${GREEN}🎉 Happy open sourcing!${NC}"
