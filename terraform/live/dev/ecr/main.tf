# Data Source: aws_iam_role
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role

data "aws_iam_role" "github_action" {
  name = "GitHubActionRole"
}

# Data: aws_lambda_function
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lambda_function

data "aws_lambda_function" "user_auth" {
  function_name = "userAuthHandler"
}

# module: ecr
# https://registry.terraform.io/modules/terraform-aws-modules/ecr/aws/latest

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.3.0"

  repository_type                 = "private"
  repository_name                 = format("%s/%s", var.env, lower(var.product))
  repository_image_tag_mutability = "IMMUTABLE"
  repository_encryption_type      = "AES256"

  repository_read_write_access_arns = [
    data.aws_iam_role.github_action.arn
  ]

  repository_lambda_read_access_arns = [
    data.aws_lambda_function.user_auth.arn
  ]

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
