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

locals {
  db_cluster_identifier = format("%s-%s", lower(var.product), var.env)
}

# Data Source: aws_db_cluster_snapshot
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/db_cluster_snapshot

data "aws_db_cluster_snapshot" "mysql" {
  count = var.restored_from_snapshot ? 1 : 0

  most_recent                    = var.db_cluster_snapshot.most_recent
  db_cluster_identifier          = local.db_cluster_identifier
  db_cluster_snapshot_identifier = var.db_cluster_snapshot.db_cluster_snapshot_identifier
  snapshot_type                  = var.db_cluster_snapshot.snapshot_type
}

# Data Source: aws_kms_key
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key

data "aws_kms_key" "secretsmanager" {
  key_id = "alias/aws/secretsmanager"
}

# module: rds-aurora
# https://registry.terraform.io/modules/terraform-aws-modules/rds-aurora/aws/latest

module "aurora_mysql" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 9.11.0"

  # DB subnet group
  create_db_subnet_group = false
  db_subnet_group_name   = data.terraform_remote_state.vpc.outputs.database_subnet_group_name

  # Cluster
  allow_major_version_upgrade                   = false
  apply_immediately                             = false
  backup_retention_period                       = 5
  name                                          = local.db_cluster_identifier
  copy_tags_to_snapshot                         = true
  database_name                                 = var.database_name
  delete_automated_backups                      = true
  deletion_protection                           = false
  enabled_cloudwatch_logs_exports               = ["audit", "error", "general", "slowquery"]
  engine                                        = "aurora-mysql"
  engine_mode                                   = "provisioned"
  engine_version                                = "8.0.mysql_aurora.3.08.0"
  engine_lifecycle_support                      = var.engine_lifecycle_support ? "open-source-rds-extended-support" : "open-source-rds-extended-support-disabled"
  final_snapshot_identifier                     = format("final-%s-%s", lower(var.product), var.env)
  iam_database_authentication_enabled           = true
  manage_master_user_password                   = true
  master_user_secret_kms_key_id                 = data.aws_kms_key.secretsmanager.key_id
  master_username                               = var.db_master_username
  network_type                                  = "IPV4"
  cluster_performance_insights_enabled          = true
  cluster_performance_insights_retention_period = 7
  preferred_backup_window                       = var.backup_window
  preferred_maintenance_window                  = var.maintenance_window
  skip_final_snapshot                           = false
  snapshot_identifier                           = var.restored_from_snapshot ? data.aws_db_cluster_snapshot.mysql[0].id : null
  storage_encrypted                             = true
  create_security_group                         = false
  vpc_security_group_ids                        = [data.terraform_remote_state.vpc.outputs.sg_rds_id]
  serverlessv2_scaling_configuration = {
    max_capacity = 16
    min_capacity = 1
  }

  # Instance
  auto_minor_version_upgrade            = true
  create_monitoring_role                = false
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  publicly_accessible                   = false
  instances = {
    instance-1 = {
      availability_zone = element(data.terraform_remote_state.vpc.outputs.azs, 0)
      instance_class    = "db.serverless"
      promotion_tier    = 1
    }
  }

  # DB parameter group
  create_db_cluster_parameter_group          = true
  db_cluster_parameter_group_use_name_prefix = false
  db_cluster_parameter_group_name            = format("%s-%s-aurora-mysql8", lower(var.product), var.env)
  db_cluster_parameter_group_description     = "The cluster parameter group for aurora-mysql8.0"
  db_cluster_parameter_group_family          = "aurora-mysql8.0"
  create_db_parameter_group                  = true
  db_parameter_group_use_name_prefix         = false
  db_parameter_group_name                    = format("%s-%s-aurora-mysql8", lower(var.product), var.env)
  db_parameter_group_description             = "The parameter group for aurora-mysql8.0"
  db_parameter_group_family                  = "aurora-mysql8.0"

  # CloudWatch Logs
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = 30
  cloudwatch_log_group_skip_destroy      = false
  cloudwatch_log_group_class             = "STANDARD"

  # Secrets Manager
  manage_master_user_password_rotation              = true
  master_user_password_rotate_immediately           = false
  master_user_password_rotation_schedule_expression = "cron(0 0 1 * ? *)"
}
