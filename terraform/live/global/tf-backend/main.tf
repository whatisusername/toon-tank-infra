locals {
  bucket_name         = format("%s-terraform-state-%s", var.s3_bucket_prefix, var.region)
  dynamodb_table_name = format("%s-terraform-locks", var.dynamodb_table_prefix)
}

# Data Source: aws_iam_role
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role

data "aws_iam_role" "terraform_dev" {
  name = "TerraformDeployDevRole"
}

# module: s3-bucket
# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest

module "terraform_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.3.0"

  bucket        = local.bucket_name
  force_destroy = true

  versioning = {
    status = "Enabled"
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule = [
    {
      id     = "ClearOldVersionObjects"
      status = "Enabled"
      noncurrent_version_expiration = {
        newer_noncurrent_versions = 5
        days                      = 30
      }
    }
  ]

  attach_public_policy = true

  attach_policy = true
  policy        = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyDeleteBucket",
      "Effect": "Deny",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:DeleteBucket",
      "Resource": "${module.terraform_bucket.s3_bucket_arn}",
      "Condition": {
        "StringNotEquals": {
          "aws:PrincipalArn": "${data.aws_iam_role.terraform_dev.arn}"
        }
      }
    }
  ]
}
EOF
}

# Resource: aws_dynamodb_table
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table

resource "aws_dynamodb_table" "main" {
  name         = local.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
