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
# VPC
################################################################################

variable "vpc_cidr" {
  type        = string
  description = "The IPv4 CIDR block for the VPC."
  default     = "172.32.0.0/16"
}

variable "az_number" {
  type        = number
  description = "The number of availability zones to use."
  default     = 2

  validation {
    condition     = var.az_number >= 2
    error_message = "The number of public subnets should be at least 2."
  }
}

variable "public_subnet_number" {
  type        = number
  description = "The number of public subnets."
  default     = 2

  validation {
    condition     = var.public_subnet_number % var.az_number == 0
    error_message = "The number of public subnets should be a multiple of az_number."
  }
}

variable "private_subnet_number" {
  type        = number
  description = "The number of private subnets."
  default     = 2

  validation {
    condition     = var.private_subnet_number % var.az_number == 0
    error_message = "The number of private subnets should be a multiple of az_number."
  }
}

variable "database_subnet_number" {
  type        = number
  description = "The number of database subnets."
  default     = 2

  validation {
    condition     = var.database_subnet_number % var.az_number == 0
    error_message = "The number of database subnets should be a multiple of az_number."
  }
}
