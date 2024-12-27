data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket  = format("%s-terraform-state-%s", lower(var.product), var.region)
    key     = format("%s/vpc/terraform.tfstate", var.env)
    region  = var.region
    profile = "TerraformBackend"
    assume_role = {
      role_arn     = "arn:aws:iam::846072081665:role/TerraformStateAccessRole"
      session_name = "TerraformSession"
    }
  }
}

# Data Source: aws_ami
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami

data "aws_ami" "al2023" {
  owners      = ["amazon"]
  most_recent = true
  name_regex  = "^al2023-ami-2023.*-x86_64$"

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# module: security-group
# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest

module "sg_bastion_host" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.2.0"

  use_name_prefix = false
  name            = format("%s-%s-bastion-host", lower(var.product), var.env)
  description     = "Security group for Bastion Host"
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id

  egress_with_source_security_group_id = [
    {
      source_security_group_id = data.terraform_remote_state.vpc.outputs.sg_rds_id
      description              = "Allow outbound traffic to RDS"
      rule                     = "mysql-tcp"
    }
  ]

  egress_with_cidr_blocks = [
    {
      cidr_blocks = "0.0.0.0/0"
      description = "Allow HTTPS outbound traffic"
      rule        = "https-443-tcp"
    }
  ]
}

# Resource: aws_vpc_security_group_ingress_rule
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule

resource "aws_vpc_security_group_ingress_rule" "rds" {
  security_group_id = data.terraform_remote_state.vpc.outputs.sg_rds_id

  description                  = "Allow inbound traffic from Bastion Host"
  referenced_security_group_id = module.sg_bastion_host.security_group_id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

# module: ec2-instance
# https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest

module "bastion_host" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.7.0"

  name                        = format("%s-%s", var.name, var.env)
  ami                         = data.aws_ami.al2023.image_id
  ignore_ami_changes          = true
  instance_type               = var.instance_type
  subnet_id                   = element(data.terraform_remote_state.vpc.outputs.public_subnets, 0)
  vpc_security_group_ids      = [module.sg_bastion_host.security_group_id]
  create_iam_instance_profile = false
  iam_instance_profile        = "BastionHostRole"
  associate_public_ip_address = true
  enable_volume_tags          = false

  root_block_device = [
    {
      delete_on_termination = true
      encrypted             = true
      volume_type           = "gp2"
      volume_size           = 8
    }
  ]

  metadata_options = {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}

# Resource: aws_network_acl_rule
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule

resource "aws_network_acl_rule" "database" {
  network_acl_id = data.terraform_remote_state.vpc.outputs.database_network_acl_id
  rule_number    = 10
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = format("%s/32", module.bastion_host.private_ip)
  from_port      = 3306
  to_port        = 3306

  depends_on = [
    module.bastion_host
  ]
}
