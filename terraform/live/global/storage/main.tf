# Data Source: aws_iam_role
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role

data "aws_iam_role" "terraform_dev" {
  name = "TerraformDeployDevRole"
}

# module: s3-bucket
# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest

module "lambda_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.3.0"

  bucket        = format("%s-lambda-function-%s", lower(var.product), var.region)
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
        newer_noncurrent_versions = 10
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
      "Resource": "${module.lambda_bucket.s3_bucket_arn}",
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
