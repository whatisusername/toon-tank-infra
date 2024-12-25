variable "region" {
  description = "Provision in which AWS region."
  type        = string
  default     = "us-west-2"
}

variable "product" {
  description = "The production name. It's for the tag."
  type        = string
  default     = "ToonTank"
}

variable "profile" {
  description = "The AWS profile for the deployment."
  type        = string
  default     = "TerraformDeploy"
}

variable "env" {
  description = "The environment name. Should be dev/stag/prod"
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^(dev|stag|prod)$", var.env))
    error_message = "The env should be dev, stag or prod."
  }
}

################################################################################
# Cognito User Pool
################################################################################

variable "post_confirmation_function_name" {
  type        = string
  description = "Post-confirmation Lambda function name."
  default     = "postUserSignUpHandler"
}

################################################################################
# EventBridge
################################################################################

variable "eventbridge_pipe_name" {
  type        = string
  description = "The name of the EventBridge Pipe."
  default     = "UserPostSignUpPipe"
}
