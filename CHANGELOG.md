# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of AWS Test Infrastructure
- Support for 28 AWS service categories
- 145+ AWS resources across multiple modules
- Comprehensive documentation
- Cost estimation and tracking
- SSH key pair generation for EC2 access
- IAM edge cases for testing (multiple policies, overlapping permissions)
- VPC endpoints for S3, DynamoDB, and Lambda
- Route53 hosted zone support
- Network ACLs for public and private subnets
- API Gateway advanced features (authorizer, usage plans, VPC link)
- Lambda layers and event configurations
- Launch configuration and launch template
- IAM users, groups, and policy attachments
- GitHub Actions for CI/CD validation
- Issue and PR templates
- Contributing guidelines and Code of Conduct

### Modules
- **Networking**: VPC, subnets, security groups, internet gateway, VPC endpoints, NACLs
- **Security**: IAM roles/policies, KMS keys, Secrets Manager, users, groups
- **Storage**: S3 buckets (versioned, encrypted), EBS volumes
- **Compute**: Lambda functions (Python, Node.js), EC2 instances, Auto Scaling, key pairs
- **Database**: DynamoDB tables, optional RDS MySQL instance
- **Messaging**: SNS topics, SQS queues (standard, FIFO, DLQ)
- **Monitoring**: CloudWatch logs/alarms/dashboards, CloudTrail
- **API**: API Gateway REST API with advanced features
- **Container**: ECR repositories, ECS clusters/services
- **Code Services**: CodeCommit, CodeBuild, optional CodePipeline
- **Orchestration**: Step Functions, EventBridge rules
- **Route53**: Hosted zones for custom domains

### Documentation
- README.md with comprehensive setup guide
- CONTRIBUTING.md with contribution guidelines
- CODE_OF_CONDUCT.md for community standards
- EDGE_CASES.md documenting special configurations
- BACKEND_SETUP.md for S3 backend configuration
- TROUBLESHOOTING.md for common issues
- COST_ESTIMATION.md with detailed cost breakdown
- IAM_PERMISSIONS.md with required permissions

### Cost Optimization
- Default configuration: ~$37/month
- Free tier eligible services prioritized
- Optional expensive services (NAT Gateway, RDS)
- Configurable module toggles
- Cost estimation in Terraform outputs

## [1.0.0] - 2026-02-16

### Initial Release
- First public release of the project
- Open source under MIT License
- Ready for community contributions

---

## Version History

### Versioning Strategy
- **Major version** (X.0.0): Breaking changes, major architectural changes
- **Minor version** (0.X.0): New features, new AWS services, non-breaking changes
- **Patch version** (0.0.X): Bug fixes, documentation updates, minor improvements

### How to Contribute to Changelog
When submitting a PR, add your changes under the `[Unreleased]` section in the appropriate category:
- **Added**: New features or resources
- **Changed**: Changes to existing functionality
- **Deprecated**: Features that will be removed in future versions
- **Removed**: Removed features or resources
- **Fixed**: Bug fixes
- **Security**: Security improvements or fixes

[Unreleased]: https://github.com/sachinjanghale/aws-test-infrastructure/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/sachinjanghale/aws-test-infrastructure/releases/tag/v1.0.0
