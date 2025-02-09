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

