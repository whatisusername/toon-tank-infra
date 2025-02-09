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
# EC2 Instance
################################################################################

variable "name" {
  type        = string
  description = "Name to be used on EC2 instance created."
  default     = "BastionHost"
}

variable "instance_type" {
  type        = string
  description = "The type of instance to start."
  default     = "t2.micro"
}
