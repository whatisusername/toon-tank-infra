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

################################################################################
# S3 Bucket
################################################################################

variable "s3_bucket_prefix" {
  type        = string
  description = "S3 bucket prefix for terraform state"
  default     = "toontank"
}

variable "create_s3_policy" {
  type        = bool
  description = "Whether to create an S3 bucket policy"
  default     = true
}

################################################################################
# DynamoDB Table
################################################################################

variable "dynamodb_table_prefix" {
  type        = string
  description = "DynamoDB table prefix for terraform state"
  default     = "toontank"
}
