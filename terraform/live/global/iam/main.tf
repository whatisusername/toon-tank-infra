# Data Source: aws_caller_identity
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity

data "aws_caller_identity" "current" {}

# submodule: iam-policy
# https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-policy

module "tf_backend_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.52.0"

  name        = "ToonTankTfBackendPolicy"
  path        = var.group_path
  description = "Allows to manage Terraform state backend."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowManageS3Bucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::toontank-terraform-state-us-west-2"
      },
      {
        Sid    = "AllowCreateS3Objects"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::toontank-terraform-state-us-west-2/*"
      },
      {
        Sid    = "AllowManageDynamoDBLocks"
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/toontank-terraform-locks"
      }
    ]
  })
}

module "assume_role_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.52.0"

  name        = "GitHubActionAssumeRolePolicy"
  path        = var.group_path
  description = "Allows GitHub Action Role to assume roles."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAssumeRole"
        Effect = "Allow"
        Action = [
          "sts:AssumeRole"
        ]
        Resource = [
          module.terraform_state_role.iam_role_arn,
          module.terraform_dev_role.iam_role_arn,
        ]
      }
    ]
  })
}

module "compute_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.52.0"

  name        = "ToonTankComputePolicy"
  path        = var.group_path
  description = "Allows to manage Compute services."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowManageRole"
        Effect = "Allow"
        Action = [
          "iam:PassRole",
        ]
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/BastionHostRole"
        ]
      },
      {
        Sid    = "AllowRetrieveLambdaFunction"
        Effect = "Allow"
        Action = [
          "lambda:GetFunction",
          "lambda:CreateFunction",
          "lambda:DeleteFunction",
          "lambda:GetFunctionCodeSigningConfig",
          "lambda:GetPolicy",
          "lambda:AddPermission",
          "lambda:RemovePermission",
          "lambda:UpdateFunctionConfiguration",
          "lambda:GetAlias",
          "lambda:CreateAlias",
          "lambda:UpdateAlias",
          "lambda:DeleteAlias",
          "lambda:PublishVersion",
          "lambda:ListVersionsByFunction",
          "lambda:TagResource",
          "lambda:UntagResource",
          "lambda:UpdateFunctionCode",
          "lambda:GetFunctionConfiguration",
        ]
        Resource = [
          "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:*"
        ]
      },
      {
        Sid    = "AllowViewEC2Info"
        Effect = "Allow"
        Action = [
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceAttribute",
          "ec2:DescribeVolumes",
          "ec2:DescribeInstanceCreditSpecifications",
          "ec2:DescribeTags",
        ]
        Resource = [
          "*"
        ]
      },
      {
        Sid    = "AllowCreateEC2Instance"
        Effect = "Allow"
        Action = [
          "ec2:RunInstances"
        ]
        Resource = [
          "*"
        ]
      },
      {
        Sid    = "AllowTerminateEC2Instance"
        Effect = "Allow"
        Action = [
          "ec2:TerminateInstances"
        ]
        Resource = [
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:instance/*"
        ]
      },
      {
        Sid    = "AllowManageECR"
        Effect = "Allow"
        Action = [
          "ecr:DescribeRepositories",
          "ecr:CreateRepository",
          "ecr:DeleteRepository",
          "ecr:DescribeImages",
          "ecr:GetLifecyclePolicy",
          "ecr:PutLifecyclePolicy",
          "ecr:DeleteLifecyclePolicy",
          "ecr:GetRepositoryPolicy",
          "ecr:SetRepositoryPolicy",
          "ecr:DeleteRepositoryPolicy",
          "ecr:ListTagsForResource",
          "ecr:TagResource",
          "ecr:UntagResource",
        ]
        Resource = [
          "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/*/toontank"
        ]
      },
      {
        Sid    = "AllowManageCloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:DeleteLogGroup",
          "logs:PutRetentionPolicy",
          "logs:DeleteRetentionPolicy",
          "logs:ListTagsForResource",
        ]
        Resource = [
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
        ]
      }
    ]
  })
}

module "database_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.52.0"

  name        = "ToonTankDatabasePolicy"
  path        = var.group_path
  description = "Allows to manage Database services."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowManageRDS"
        Effect = "Allow"
        Action = [
          "rds:DescribeGlobalClusters",
          "rds:DescribeDBClusters",
          "rds:CreateDBCluster",
          "rds:DeleteDBCluster",
          "rds:ModifyDBCluster",
          "rds:DescribeDBClusterParameterGroups",
          "rds:DescribeDBClusterParameters",
          "rds:CreateDBClusterParameterGroup",
          "rds:DeleteDBClusterParameterGroup",
          "rds:ModifyDBClusterParameterGroup",
          "rds:DescribeDBInstances",
          "rds:CreateDBInstance",
          "rds:DeleteDBInstance",
          "rds:ModifyDBInstance",
          "rds:DescribeDBParameterGroups",
          "rds:DescribeDBParameters",
          "rds:CreateDBParameterGroup",
          "rds:DeleteDBParameterGroup",
          "rds:ModifyDBParameterGroup",
          "rds:ListTagsForResource",
          "rds:DescribeDBSubnetGroups",
          "rds:DescribeDBSnapshots",
          "rds:DescribeDBClusterSnapshots",
          "rds:CreateDBClusterSnapshot",
          "rds:DeleteDBClusterSnapshot",
        ]
        Resource = [
          "*"
        ]
      },
      {
        Sid    = "AllowManageDBInstance"
        Effect = "Allow"
        Action = [
          "rds:ModifyDBInstance",
          "rds:DeleteDBInstance",
        ]
        Resource = [
          "arn:aws:rds:${var.region}:${data.aws_caller_identity.current.account_id}:db:*"
        ]
      },
      {
        Sid    = "AllowManageDBSubnetGroup"
        Effect = "Allow"
        Action = [
          "rds:CreateDBSubnetGroup",
          "rds:DeleteDBSubnetGroup",
          "rds:ModifyDBSubnetGroup",
        ]
        Resource = [
          "arn:aws:rds:${var.region}:${data.aws_caller_identity.current.account_id}:subgrp:toontank*"
        ]
      },
      {
        Sid    = "AllowManageRDSEvent"
        Effect = "Allow"
        Action = [
          "rds:DescribeEventSubscriptions",
          "rds:CreateEventSubscription",
          "rds:DeleteEventSubscription",
          "rds:ModifyEventSubscription"
        ]
        Resource = [
          "arn:aws:rds:${var.region}:${data.aws_caller_identity.current.account_id}:es:*"
        ]
      },
      {
        Sid    = "AllowManageCloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:DeleteLogGroup",
          "logs:PutRetentionPolicy",
          "logs:ListTagsForResource",
        ]
        Resource = [
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/rds/*"
        ]
      },
      {
        Sid    = "AllowManageTags"
        Effect = "Allow"
        Action = [
          "rds:AddTagsToResource",
          "rds:RemoveTagsFromResource",
          "logs:TagResource",
          "logs:UntagResource",
        ]
        Resource = [
          "*"
        ]
      },
      {
        Sid    = "AllowRetrieveKMS"
        Effect = "Allow"
        Action = [
          "kms:DescribeKey",
        ]
        Resource = [
          "arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:key/*"
        ]
        Condition = {
          "ForAnyValue:StringEquals" = {
            "kms:ResourceAliases" = "alias/aws/secretsmanager"
          }
        }
      },
      {
        Sid    = "AllowManageSecrets"
        Effect = "Allow"
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:CreateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:TagResource",
          "secretsmanager:UntagResource",
          "secretsmanager:PutResourcePolicy",
          "secretsmanager:RotateSecret",
          "secretsmanager:CancelRotateSecret",
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:rds!cluster-*"
        ]
      },
      {
        Sid    = "AllowRestoreFromSnapshot"
        Effect = "Allow"
        Action = [
          "rds:RestoreDBClusterFromSnapshot",
        ]
        Resource = [
          "*"
        ]
        Condition = {
          Null = {
            "aws:ResourceTag/Product" = "false"
          }
          StringEquals = {
            "aws:ResourceTag/Product" = var.product
          }
        }
      }
    ]
  })
}

module "network_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.52.0"

  name        = "ToonTankNetworkPolicy"
  path        = var.group_path
  description = "Allows to manage Networking & Content Delivery services."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowManageVpc"
        Effect = "Allow"
        Action = [
          "ec2:CreateVpc",
          "ec2:DeleteVpc",
          "ec2:ModifyVpcAttribute",
        ]
        Resource = [
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:vpc/*"
        ]
      },
      {
        Sid    = "AllowViewVpc"
        Effect = "Allow"
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeRouteTables",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribeAvailabilityZones",
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowManageInternetGateway"
        Effect = "Allow"
        Action = [
          "ec2:CreateInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:AttachInternetGateway",
          "ec2:DetachInternetGateway",
        ]
        Resource = [
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:vpc/*",
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:internet-gateway/*"
        ]
      },
      {
        Sid    = "AllowManageSecurityGroup"
        Effect = "Allow"
        Action = [
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
        ]
        Resource = [
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:vpc/*",
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:security-group/*"
        ]
      },
      {
        Sid    = "AllowManageRoute"
        Effect = "Allow"
        Action = [
          "ec2:CreateSubnet",
          "ec2:DeleteSubnet",
          "ec2:ModifySubnetAttribute",
          "ec2:CreateRouteTable",
          "ec2:DeleteRouteTable",
          "ec2:CreateRoute",
          "ec2:DeleteRoute",
          "ec2:AssociateRouteTable",
          "ec2:DisassociateRouteTable",
          "ec2:ReplaceNetworkAclAssociation",
          "ec2:CreateNetworkAcl",
          "ec2:DeleteNetworkAcl",
          "ec2:CreateNetworkAclEntry",
          "ec2:DeleteNetworkAclEntry",
          "ec2:ReplaceNetworkAclEntry",
          "ec2:ReplaceRouteTableAssociation",
        ]
        Resource = [
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:vpc/*",
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:route-table/*",
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:subnet/*",
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:network-acl/*",
        ]
      },
      {
        Sid    = "AllowManageTags"
        Effect = "Allow"
        Action = [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowManageSGTraffic"
        Effect = "Allow"
        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
        ]
        Resource = [
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:security-group/*",
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:security-group-rule/*",
        ]
      },
      {
        Sid    = "AllowViewSGRules"
        Effect = "Allow"
        Action = [
          "ec2:DescribeSecurityGroupRules",
        ]
        Resource = "*"
      }
    ]
  })
}

module "security_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.52.0"

  name        = "ToonTankSecurityPolicy"
  path        = var.group_path
  description = "Allows to manage Security, Identiry, and Compliance services."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowRetrieveIAMResources"
        Effect = "Allow"
        Action = [
          "iam:GetRole"
        ]
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/TerraformDeployDevRole",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/bot/GitHubActionRole",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role${var.group_path}PostUserSignUpHandlerLambdaRole",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role${var.group_path}PostUserSignUpPipeRole",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role${var.group_path}PostUserSignUpStepFunctionsRole",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role${var.group_path}UserAuthHandlerLambdaRole",
        ]
      },
      {
        Sid    = "AllowPassRole"
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role${var.group_path}PostUserSignUpHandlerLambdaRole",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role${var.group_path}PostUserSignUpPipeRole",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role${var.group_path}PostUserSignUpStepFunctionsRole",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role${var.group_path}UserAuthHandlerLambdaRole",
        ]
      },
      {
        Sid    = "AllowManageUserPool"
        Effect = "Allow"
        Action = [
          "cognito-idp:DescribeUserPool",
          "cognito-idp:UpdateUserPool",
          "cognito-idp:DeleteUserPool",
          "cognito-idp:DescribeUserPoolClient",
          "cognito-idp:CreateUserPoolClient",
          "cognito-idp:UpdateUserPoolClient",
          "cognito-idp:DeleteUserPoolClient",
          "cognito-idp:CreateUserPoolDomain",
          "cognito-idp:UpdateUserPoolDomain",
          "cognito-idp:DeleteUserPoolDomain",
          "cognito-idp:DescribeResourceServer",
          "cognito-idp:CreateResourceServer",
          "cognito-idp:UpdateResourceServer",
          "cognito-idp:DeleteResourceServer",
          "cognito-idp:GetUserPoolMfaConfig",
          "cognito-idp:TagResource",
          "cognito-idp:UntagResource",
        ]
        Resource = [
          "arn:aws:cognito-idp:${var.region}:${data.aws_caller_identity.current.account_id}:userpool/*"
        ]
      },
      {
        Sid    = "AllowRetrieveCognito"
        Effect = "Allow"
        Action = [
          "cognito-idp:DescribeUserPoolDomain",
          "cognito-idp:CreateUserPool",
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowManageSecrets"
        Effect = "Allow"
        Action = [
          "secretsmanager:CreateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:RotateSecret",
          "secretsmanager:UpdateSecret",
          "secretsmanager:UpdateSecretVersionStage",
          "secretsmanager:DescribeSecret",
          "secretsmanager:TagResource",
          "secretsmanager:UntagResource",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
        ]
        Resource = "arn:aws:secretsmanager:*:${data.aws_caller_identity.current.account_id}:secret:toontank*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = ["us-east-1", "us-west-2"]
          }
        }
      }
    ]
  })
}

module "storage_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.52.0"

  name        = "ToonTankStoragePolicy"
  path        = var.group_path
  description = "Allows to manage Storage services."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowManageS3Bucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:GetBucketPolicy",
          "s3:PutBucketPolicy",
          "s3:DeleteBucketPolicy",
          "s3:GetBucketAcl",
          "s3:GetLifecycleConfiguration",
          "s3:PutLifecycleConfiguration",
          "s3:GetBucketPublicAccessBlock",
          "s3:PutBucketPublicAccessBlock",
          "s3:GetEncryptionConfiguration",
          "s3:PutEncryptionConfiguration",
          "s3:GetBucketVersioning",
          "s3:PutBucketVersioning",
          "s3:GetBucketWebsite",
          "s3:GetBucketCORS",
          "s3:GetBucketRequestPayment",
          "s3:GetBucketObjectLockConfiguration",
          "s3:GetBucketLogging",
          "s3:GetBucketTagging",
          "s3:PutBucketTagging",
          "s3:GetAccelerateConfiguration",
          "s3:GetReplicationConfiguration",
          "s3:ListBucketVersions",
        ]
        Resource = [
          "arn:aws:s3:::toontank-lambda-function-us-west-2",
          "arn:aws:s3:::toontank-terraform-state-us-west-2",
        ]
      },
      {
        Sid    = "AllowManageS3Object"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectTagging",
          "s3:PutObjectTagging",
          "s3:DeleteObjectTagging",
          "s3:GetObjectVersion",
          "s3:DeleteObjectVersion",
        ]
        Resource = [
          "arn:aws:s3:::toontank-lambda-function-us-west-2/*",
        ]
      },
      {
        Sid    = "AllowManageDynamoDBLocks"
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:CreateTable",
          "dynamodb:DeleteTable",
          "dynamodb:DescribeContinuousBackups",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:ListTagsOfResource",
        ]
        Resource = "arn:aws:dynamodb:*:*:table/toontank-terraform-locks"
      }
    ]
  })
}

module "integration_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.52.0"

  name        = "ToonTankIntegrationPolicy"
  path        = var.group_path
  description = "Allows to manage Application Integration services."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowManageSQS"
        Effect = "Allow"
        Action = [
          "sqs:CreateQueue",
          "sqs:DeleteQueue",
          "sqs:AddPermission",
          "sqs:RemovePermission",
          "sqs:TagQueue",
          "sqs:UntagQueue",
          "sqs:GetQueueAttributes",
          "sqs:ListQueueTags",
          "sqs:GetQueueUrl",
        ]
        Resource = [
          "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
        ]
      },
      {
        Sid    = "AllowManageStepFunctions"
        Effect = "Allow"
        Action = [
          "states:CreateStateMachine",
          "states:DeleteStateMachine",
          "states:TagResource",
          "states:UntagResource",
          "states:ValidateStateMachineDefinition",
          "states:DescribeStateMachine",
          "states:ListStateMachineVersions",
          "states:ListTagsForResource",
        ]
        Resource = [
          "arn:aws:states:${var.region}:${data.aws_caller_identity.current.account_id}:stateMachine:*"
        ]
      },
      {
        Sid    = "AllowManageEventBridgePipe"
        Effect = "Allow"
        Action = [
          "pipes:CreatePipe",
          "pipes:DeletePipe",
          "pipes:UpdatePipe",
          "pipes:TagResource",
          "pipes:UntagResource",
          "pipes:DescribePipe",
          "pipes:ListTagsForResource",
        ]
        Resource = [
          "arn:aws:pipes:${var.region}:${data.aws_caller_identity.current.account_id}:pipe/*"
        ]
      },
      {
        Sid    = "AllowManageEventBridge"
        Effect = "Allow"
        Action = [
          "events:DescribeEventBus",
        ]
        Resource = [
          "arn:aws:events:${var.region}:${data.aws_caller_identity.current.account_id}:event-bus/*"
        ]
      },
      {
        Sid    = "AllowManageLog"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:DeleteLogGroup",
          "logs:PutRetentionPolicy",
          "logs:DeleteRetentionPolicy",
          "logs:ListTagsForResource",
        ]
        Resource = [
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/pipes/*",
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vendedlogs/states/*",
        ]
      },
      {
        Sid    = "AllowRetrieveLogGroup"
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
        ]
        Resource = [
          "*"
        ]
      },
      {
        Sid    = "AllowManageLogDelivery"
        Effect = "Allow"
        Action = [
          "logs:ListLogDeliveries",
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}

module "secrets_readonly_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.52.0"

  name        = "SecretValueReadOnlyPolicy"
  path        = "/"
  description = "Allows to read the secret values."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowGetSecretValue"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:*"
        ]
      }
    ]
  })
}

module "ssm_connect_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.52.0"

  name        = "SessionManagerConnectPolicy"
  path        = "/"
  description = "Allows to connect via Session Manager."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:StartSession",
          "ssm:SendCommand",
        ]
        Resource = [
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:instance/*"
        ]
        Condition = {
          StringLike = {
            "ssm:resourceTag/Name" = "BastionHost*"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:DescribeSessions",
          "ssm:GetConnectionStatus",
          "ssm:DescribeInstanceInformation",
          "ssm:DescribeInstanceProperties",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:CreateDocument",
          "ssm:UpdateDocument",
          "ssm:GetDocument",
          "ssm:StartSession"
        ]
        Resource = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:document/SSM-SessionManagerRunShell"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:TerminateSession",
          "ssm:ResumeSession"
        ]
        Resource = "arn:aws:ssm:*:*:session/*"
      }
    ]
  })
}

# submodule: iam-github-oidc-provider
# https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-github-oidc-provider

module "github_oidc_provider" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider"
  version = "~> 5.52.0"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}

# submodule: iam-github-oidc-role
# https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-github-oidc-role

data "aws_iam_policy" "ecr_power_user" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

module "github_action_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"
  version = "~> 5.52.0"

  name                 = "GitHubActionRole"
  path                 = "/bot/"
  description          = "Allows GitHub Actions to assume this role to access AWS resources."
  max_session_duration = 3600
  policies = {
    ecr_power_user = data.aws_iam_policy.ecr_power_user.arn
    get_secret     = module.secrets_readonly_policy.arn
    assume_role    = module.assume_role_policy.arn
  }
  subjects = [
    "whatisusername/toon-tank-user-service:ref:refs/heads/main",
    "whatisusername/toon-tank-user-service:ref:refs/tags/v*",
    "whatisusername/toon-tank-post-signup-service:ref:refs/heads/main",
    "whatisusername/toon-tank-user-db-service:ref:refs/heads/main",
  ]
}

# submodule: iam-assumable-role
# https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-assumable-role

module "terraform_state_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.52.0"

  create_role          = true
  role_name            = "TerraformStateAccessRole"
  role_path            = "/"
  role_description     = "Allows Terraform manage the state files."
  max_session_duration = 3600
  role_requires_mfa    = false

  trusted_role_arns = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]

  trust_policy_conditions = [
    {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_TerraformBackend_*",
        module.github_action_role.arn,
      ]
    }
  ]

  custom_role_policy_arns = [
    module.tf_backend_policy.arn
  ]
}

data "aws_iam_policy" "iam_full_access" {
  name = "IAMFullAccess"
}

module "terraform_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.52.0"

  create_role          = true
  role_name            = "TerraformDeployIAMRole"
  role_path            = "/"
  role_description     = "Allows Terraform deploy the IAM resources."
  max_session_duration = 3600
  role_requires_mfa    = false

  trusted_role_arns = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]

  trust_policy_conditions = [
    {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_IAMManager_*",
      ]
    }
  ]

  custom_role_policy_arns = [
    data.aws_iam_policy.iam_full_access.arn,
  ]
}

module "terraform_dev_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.52.0"

  create_role          = true
  role_name            = "TerraformDeployDevRole"
  role_path            = "/"
  role_description     = "Allows Terraform deploy the AWS resources."
  max_session_duration = 3600
  role_requires_mfa    = false

  trusted_role_arns = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]

  trust_policy_conditions = [
    {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_TerraformDeploy_*",
        module.github_action_role.arn
      ]
    }
  ]

  custom_role_policy_arns = [
    module.compute_policy.arn,
    module.database_policy.arn,
    module.network_policy.arn,
    module.security_policy.arn,
    module.storage_policy.arn,
    module.integration_policy.arn,
  ]
}

data "aws_iam_policy" "ssm_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

module "bastion_host_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.52.0"

  create_role          = true
  role_name            = "BastionHostRole"
  role_path            = "/"
  role_description     = "Allows EC2 instance to be connected via Session Manager."
  max_session_duration = 3600

  role_requires_mfa     = false
  trusted_role_services = ["ec2.amazonaws.com"]

  custom_role_policy_arns = [
    data.aws_iam_policy.ssm_core.arn
  ]

  create_instance_profile = true
}

module "ssm_connect_bastion_host_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.52.0"

  create_role          = true
  role_name            = "SSMConnectBastionHostRole"
  role_path            = "/"
  role_description     = "Allows to connect the EC2 instance via SSM."
  max_session_duration = 3600
  role_requires_mfa    = false

  trusted_role_arns = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]

  custom_role_policy_arns = [
    module.ssm_connect_policy.arn
  ]
}

module "user_auth_lambda_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.52.0"

  create_role          = true
  role_name            = "UserAuthHandlerLambdaRole"
  role_path            = var.group_path
  role_description     = "Allows Lambda Function to access user auth related resources."
  max_session_duration = 3600

  role_requires_mfa     = false
  trusted_role_actions  = ["sts:AssumeRole"]
  trusted_role_services = ["lambda.amazonaws.com"]

  inline_policy_statements = [
    {
      sid    = "AllowCreateLogGroups"
      effect = "Allow"
      actions = [
        "logs:CreateLogGroup",
      ]
      resources = [
        "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
      ]
    },
    {
      sid    = "AllowPutLogEvents"
      effect = "Allow"
      actions = [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
      ]
      resources = [
        "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/userAuthHandler*"
      ]
    },
    {
      sid    = "AllowGetCognitoSecrets"
      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue",
      ]
      resources = [
        "arn:aws:secretsmanager:us-west-2:${data.aws_caller_identity.current.account_id}:secret:toontank-cognito-secrets-*"
      ]
    }
  ]
}

module "post_user_sign_up_lambda_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.52.0"

  create_role          = true
  role_name            = "PostUserSignUpHandlerLambdaRole"
  role_path            = var.group_path
  role_description     = "Allows Lambda Function to execute post user sign up actions."
  max_session_duration = 3600

  role_requires_mfa     = false
  trusted_role_actions  = ["sts:AssumeRole"]
  trusted_role_services = ["lambda.amazonaws.com"]

  inline_policy_statements = [
    {
      sid    = "AllowCreateLogGroups"
      effect = "Allow"
      actions = [
        "logs:CreateLogGroup",
      ]
      resources = [
        "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
      ]
    },
    {
      sid    = "AllowPutLogEvents"
      effect = "Allow"
      actions = [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
      ]
      resources = [
        "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/postUserSignUpHandler:*"
      ]
    },
    {
      sid    = "AllowSendMessageToSQS"
      effect = "Allow"
      actions = [
        "sqs:SendMessage",
      ]
      resources = [
        "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:SignUpConfirmationQueue"
      ]
    }
  ]
}

module "post_sign_up_eventbridge_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.52.0"

  create_role          = true
  role_name            = "PostUserSignUpPipeRole"
  role_path            = var.group_path
  role_description     = "Allows EventBridge Pipes to execute post user sign up actions."
  max_session_duration = 3600

  role_requires_mfa     = false
  trusted_role_actions  = ["sts:AssumeRole"]
  trusted_role_services = ["pipes.amazonaws.com"]
  trust_policy_conditions = [
    {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["${data.aws_caller_identity.current.account_id}"]
    },
    {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:pipes:${var.region}:${data.aws_caller_identity.current.account_id}:pipe/UserPostSignUpPipe"]
    }
  ]

  inline_policy_statements = [
    {
      sid    = "AllowPutLogEvents"
      effect = "Allow"
      actions = [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
      ]
      resources = [
        "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/pipes/UserPostSignUpPipe:*"
      ]
    },
    {
      sid    = "AllowHandleSQSMessage"
      effect = "Allow"
      actions = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
      ]
      resources = [
        "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:SignUpConfirmationQueue"
      ]
    },
    {
      sid    = "AllowExecuteSfn"
      effect = "Allow"
      actions = [
        "states:StartSyncExecution",
      ]
      resources = [
        "arn:aws:states:${var.region}:${data.aws_caller_identity.current.account_id}:stateMachine:UserPostSignUp"
      ]
    }
  ]
}

module "post_sign_up_sfn_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.52.0"

  create_role          = true
  role_name            = "PostUserSignUpStepFunctionsRole"
  role_path            = var.group_path
  role_description     = "Allows Step Functions to execute post user sign up actions."
  max_session_duration = 3600

  role_requires_mfa     = false
  trusted_role_actions  = ["sts:AssumeRole"]
  trusted_role_services = ["states.amazonaws.com"]

  inline_policy_statements = [
    {
      sid    = "AllowPutLogEvents"
      effect = "Allow"
      actions = [
        "logs:CreateLogDelivery",
        "logs:GetLogDelivery",
        "logs:UpdateLogDelivery",
        "logs:DeleteLogDelivery",
        "logs:ListLogDeliveries",
        "logs:PutResourcePolicy",
        "logs:DescribeResourcePolicies",
        "logs:DescribeLogGroups",
      ]
      resources = [
        "*"
      ]
    },
    {
      sid    = "AllowHandleSQSMessage"
      effect = "Allow"
      actions = [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords",
        "xray:GetSamplingRules",
        "xray:GetSamplingTargets",
      ]
      resources = [
        "*"
      ]
    }
  ]
}
