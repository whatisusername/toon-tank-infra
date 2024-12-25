# Data: aws_lambda_function
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lambda_function

data "aws_lambda_function" "post_confirmation" {
  function_name = var.post_confirmation_function_name
}

# module: cognito-user-pool
# https://github.com/lgallard/terraform-aws-cognito-user-pool

module "cognito_user_pool" {
  source = "lgallard/cognito-user-pool/aws"

  alias_attributes         = ["email"]
  auto_verified_attributes = ["email"]
  user_pool_name           = "ToonTankUserPool"
  mfa_configuration        = "OFF"

  username_configuration = {
    case_sensitive = false
  }

  admin_create_user_config = {
    allow_admin_create_user_only = false
  }

  email_configuration = {
    email_sending_account = "COGNITO_DEFAULT"
  }

  lambda_config = {
    post_confirmation = data.aws_lambda_function.post_confirmation.arn
  }

  password_policy = {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = false
    require_uppercase                = true
    temporary_password_validity_days = 3
  }

  string_schemas = [
    {
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = true
      name                     = "email"
      required                 = true

      string_attribute_constraints = {
        max_length = 2048
        min_length = 0
      }
    }
  ]

  verification_message_template = {
    default_email_option  = "CONFIRM_WITH_LINK"
    email_message_by_link = "Please click the link below to verify your email address. {##Verify Email##}"
    email_subject_by_link = "Your verification link"
  }

  user_attribute_update_settings = {
    attributes_require_verification_before_update = [
      "email"
    ]
  }

  domain = lower(var.product)

  clients = [
    {
      allowed_oauth_flows_user_pool_client = true
      allowed_oauth_flows                  = ["code"]
      allowed_oauth_scopes                 = ["email", "openid"]
      auth_session_validity                = 3
      callback_urls                        = ["https://d84l1y8p4kdic.cloudfront.net"]
      explicit_auth_flows                  = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
      generate_secret                      = true
      name                                 = "client"
      access_token_validity                = 10
      id_token_validity                    = 10
      refresh_token_validity               = 1
      supported_identity_providers         = ["COGNITO"]
      token_validity_units = {
        access_token  = "minutes"
        id_token      = "minutes"
        refresh_token = "days"
      }
    }
  ]
}

# module: secrets-manager
# https://registry.terraform.io/modules/terraform-aws-modules/secrets-manager/aws/latest

module "cognito_user_pool_secrets" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "~> 1.3.0"

  name                    = format("%s-cognito-secrets-%s", lower(var.product), var.env)
  description             = "Secrets that stored the info of Cognito User Pool"
  recovery_window_in_days = 0
  secret_string = templatefile("${path.module}/templates/cognito-secrets.tftpl", {
    user_pool_id   = module.cognito_user_pool.id
    client_id      = module.cognito_user_pool.client_ids_map["client"]
    client_secrets = module.cognito_user_pool.client_secrets_map["client"]
  })

  depends_on = [
    module.cognito_user_pool
  ]
}

# Resource: aws_lambda_permission
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission

resource "aws_lambda_permission" "allow_cognito_invoke" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = var.post_confirmation_function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = module.cognito_user_pool.arn
}

# module: sqs
# https://registry.terraform.io/modules/terraform-aws-modules/sqs/aws/latest

module "post_sign_up_sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "~> 4.2.0"

  name                       = "SignUpConfirmationQueue"
  message_retention_seconds  = 86400
  visibility_timeout_seconds = 30
}

# Data Source: aws_iam_role
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role

data "aws_iam_role" "post_sign_up_sfn" {
  name = "PostUserSignUpStepFunctionsRole"
}

data "aws_iam_role" "post_sign_up_pipes" {
  name = "PostUserSignUpPipeRole"
}

# module: step-functions
# https://registry.terraform.io/modules/terraform-aws-modules/step-functions/aws/latest

module "post_sign_up_sfn" {
  source  = "terraform-aws-modules/step-functions/aws"
  version = "~> 4.2.0"

  name              = "UserPostSignUp"
  type              = "EXPRESS"
  use_existing_role = true
  role_arn          = data.aws_iam_role.post_sign_up_sfn.arn
  definition = templatefile("${path.module}/templates/sfn-post-signup.tftpl", {})

  logging_configuration = {
    include_execution_data = true
    level                  = "ALL"
  }
  use_existing_cloudwatch_log_group      = false
  cloudwatch_log_group_retention_in_days = 30
}

# Resource: aws_cloudwatch_log_group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group

resource "aws_cloudwatch_log_group" "pipes" {
  name              = format("/aws/pipes/%s", var.eventbridge_pipe_name)
  retention_in_days = 30
  log_group_class   = "STANDARD"
}

# module: eventbridge
# https://registry.terraform.io/modules/terraform-aws-modules/eventbridge/aws/latest

module "post_sign_up_pipes" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "~> 3.13.0"

  append_pipe_postfix = false
  create_bus          = false
  create_role         = false

  pipes = {
    "${var.eventbridge_pipe_name}" = {
      role_arn = data.aws_iam_role.post_sign_up_pipes.arn
      source   = module.post_sign_up_sqs.queue_arn
      target   = module.post_sign_up_sfn.state_machine_arn

      source_parameters = {
        sqs_queue_parameters = {
          batch_size                         = 10
          maximum_batching_window_in_seconds = 5
        }
      }

      target_parameters = {
        step_function_state_machine_parameters = {
          invocation_type = "FIRE_AND_FORGET"
        }
      }

      log_configuration = {
        include_execution_data = []
        level                  = "ERROR"
        cloudwatch_logs_log_destination = {
          log_group_arn = aws_cloudwatch_log_group.pipes.arn
        }
      }
    }
  }

  depends_on = [
    module.post_sign_up_sqs,
    module.post_sign_up_sfn,
    aws_cloudwatch_log_group.pipes
  ]
}
