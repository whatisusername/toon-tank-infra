# Data Source: aws_availability_zones
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az_number             = var.az_number <= length(data.aws_availability_zones.available.names) ? var.az_number : length(data.aws_availability_zones.available.names)
  azs                   = slice(data.aws_availability_zones.available.names, 0, local.az_number)
  public_subnet_cidrs   = [for i in range(var.public_subnet_number) : cidrsubnet(var.vpc_cidr, 4, i)]
  private_subnet_cidrs  = [for i in range(var.private_subnet_number) : cidrsubnet(var.vpc_cidr, 4, i * 2 + 8)]
  database_subnet_cidrs = [for i in range(var.database_subnet_number) : cidrsubnet(var.vpc_cidr, 4, i * 2 + 9)]
}

# module: vpc
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.17.0"

  name = format("%s-%s", lower(var.product), var.env)
  azs  = local.azs
  cidr = var.vpc_cidr

  enable_ipv6        = false
  enable_nat_gateway = false

  manage_default_security_group = false
  manage_default_network_acl    = false
  manage_default_route_table    = false

  public_subnets                      = local.public_subnet_cidrs
  public_subnet_suffix                = "subnet-public"
  map_public_ip_on_launch             = true
  create_multiple_public_route_tables = false

  private_subnets               = local.private_subnet_cidrs
  private_subnet_suffix         = "subnet-private"
  private_dedicated_network_acl = true
  one_nat_gateway_per_az        = true

  database_subnets                   = local.database_subnet_cidrs
  database_subnet_suffix             = "subnet-database"
  create_database_subnet_route_table = true
  database_dedicated_network_acl     = true
  database_inbound_acl_rules = [for i, cidr in local.private_subnet_cidrs : {
    rule_number = 100 + i * 10
    rule_action = "allow"
    from_port   = 3306
    to_port     = 3306
    protocol    = "-1"
    cidr_block  = cidr
  }]
  create_database_subnet_group = true
  database_subnet_group_name   = format("%s-%s-subnet-group", lower(var.product), var.env)
}

# module: security-group
# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest

module "sg_rds" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.2.0"

  use_name_prefix = false
  name            = format("%s-%s-rds", lower(var.product), var.env)
  description     = "Security group for RDS"
  vpc_id          = module.vpc.vpc_id
}
