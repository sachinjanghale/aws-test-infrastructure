# Required IAM Permissions

This document lists the IAM permissions required to provision the AWS test infrastructure.

## Minimum Required Permissions

For production use, create a custom IAM policy with these specific permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EC2Permissions",
      "Effect": "Allow",
      "Action": [
        "ec2:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "IAMPermissions",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:GetRole",
        "iam:PassRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:GetRolePolicy",
        "iam:CreateInstanceProfile",
        "iam:DeleteInstanceProfile",
        "iam:GetInstanceProfile",
        "iam:AddRoleToInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:ListInstanceProfilesForRole",
        "iam:ListAttachedRolePolicies",
        "iam:ListRolePolicies"
      ],
      "Resource": "*"
    },
    {
      "Sid": "S3Permissions",
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "LambdaPermissions",
      "Effect": "Allow",
      "Action": [
        "lambda:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DynamoDBPermissions",
      "Effect": "Allow",
      "Action": [
        "dynamodb:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "RDSPermissions",
      "Effect": "Allow",
      "Action": [
        "rds:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "KMSPermissions",
      "Effect": "Allow",
      "Action": [
        "kms:CreateKey",
        "kms:CreateAlias",
        "kms:DeleteAlias",
        "kms:DescribeKey",
        "kms:GetKeyPolicy",
        "kms:PutKeyPolicy",
        "kms:EnableKeyRotation",
        "kms:DisableKeyRotation",
        "kms:GetKeyRotationStatus",
        "kms:ScheduleKeyDeletion",
        "kms:TagResource",
        "kms:UntagResource",
        "kms:ListResourceTags"
      ],
      "Resource": "*"
    },
    {
      "Sid": "SecretsManagerPermissions",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "SNSSQSPermissions",
      "Effect": "Allow",
      "Action": [
        "sns:*",
        "sqs:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "CloudWatchPermissions",
      "Effect": "Allow",
      "Action": [
        "logs:*",
        "cloudwatch:*",
        "events:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "CloudTrailPermissions",
      "Effect": "Allow",
      "Action": [
        "cloudtrail:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "APIGatewayPermissions",
      "Effect": "Allow",
      "Action": [
        "apigateway:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ECSECRPermissions",
      "Effect": "Allow",
      "Action": [
        "ecs:*",
        "ecr:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "CodeServicesPermissions",
      "Effect": "Allow",
      "Action": [
        "codecommit:*",
        "codebuild:*",
        "codepipeline:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "StepFunctionsPermissions",
      "Effect": "Allow",
      "Action": [
        "states:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## Recommended for Testing

For testing purposes, you can use the AWS managed policy:

- **PowerUserAccess**: Provides full access to AWS services except IAM and Organizations

This is simpler but provides more permissions than necessary.

## Creating IAM User for Terraform

```bash
# Create IAM user
aws iam create-user --user-name terraform-infrasyn

# Attach policy (using managed policy for simplicity)
aws iam attach-user-policy \
  --user-name terraform-infrasyn \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess

# Create access key
aws iam create-access-key --user-name terraform-infrasyn
```

Save the Access Key ID and Secret Access Key securely.

## Configuring AWS Credentials

```bash
# Configure AWS CLI
aws configure

# Or set environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ap-south-1"
```

## Permissions by Module

### Security Module
- `iam:*` - Create roles, policies, instance profiles
- `kms:*` - Create and manage KMS keys
- `secretsmanager:*` - Create and manage secrets

### Networking Module
- `ec2:CreateVpc`, `ec2:DeleteVpc`
- `ec2:CreateSubnet`, `ec2:DeleteSubnet`
- `ec2:CreateInternetGateway`, `ec2:AttachInternetGateway`
- `ec2:CreateRouteTable`, `ec2:CreateRoute`
- `ec2:CreateSecurityGroup`, `ec2:AuthorizeSecurityGroupIngress`
- `ec2:CreateNatGateway` (if enabled)
- `ec2:AllocateAddress` (for NAT Gateway)

### Storage Module
- `s3:CreateBucket`, `s3:DeleteBucket`
- `s3:PutBucketVersioning`, `s3:PutBucketEncryption`
- `s3:PutLifecycleConfiguration`
- `ec2:CreateVolume`, `ec2:DeleteVolume`

### Compute Module
- `lambda:CreateFunction`, `lambda:DeleteFunction`
- `lambda:UpdateFunctionCode`, `lambda:UpdateFunctionConfiguration`
- `ec2:RunInstances`, `ec2:TerminateInstances`
- `autoscaling:CreateAutoScalingGroup`, `autoscaling:DeleteAutoScalingGroup`
- `ec2:CreateLaunchTemplate`

### Database Module
- `dynamodb:CreateTable`, `dynamodb:DeleteTable`
- `dynamodb:UpdateTable`
- `rds:CreateDBInstance`, `rds:DeleteDBInstance` (if enabled)
- `rds:CreateDBSubnetGroup`

### Messaging Module
- `sns:CreateTopic`, `sns:DeleteTopic`
- `sqs:CreateQueue`, `sqs:DeleteQueue`
- `sns:Subscribe`

### Monitoring Module
- `logs:CreateLogGroup`, `logs:DeleteLogGroup`
- `cloudwatch:PutMetricAlarm`, `cloudwatch:DeleteAlarms`
- `cloudwatch:PutDashboard`, `cloudwatch:DeleteDashboards`
- `cloudtrail:CreateTrail`, `cloudtrail:DeleteTrail`

### API Module
- `apigateway:*` - Full API Gateway permissions

### Container Module
- `ecr:CreateRepository`, `ecr:DeleteRepository`
- `ecs:CreateCluster`, `ecs:DeleteCluster`
- `ecs:CreateService`, `ecs:DeleteService`
- `ecs:RegisterTaskDefinition`, `ecs:DeregisterTaskDefinition`

### Code Services Module
- `codecommit:CreateRepository`, `codecommit:DeleteRepository`
- `codebuild:CreateProject`, `codebuild:DeleteProject`
- `codepipeline:CreatePipeline`, `codepipeline:DeletePipeline` (if enabled)

### Orchestration Module
- `states:CreateStateMachine`, `states:DeleteStateMachine`
- `events:PutRule`, `events:DeleteRule`
- `events:PutTargets`, `events:RemoveTargets`

## Security Best Practices

1. **Use IAM Roles** instead of access keys when possible
2. **Enable MFA** for IAM users
3. **Rotate access keys** regularly
4. **Use least privilege** - only grant required permissions
5. **Enable CloudTrail** to audit API calls
6. **Review IAM policies** periodically
7. **Use separate AWS accounts** for dev/test/prod

## Troubleshooting Permission Issues

If you encounter permission errors:

1. Check CloudTrail for the specific denied action:
```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=<ActionName> \
  --max-results 5
```

2. Add the missing permission to your IAM policy

3. Wait a few minutes for IAM changes to propagate

4. Retry the Terraform operation
