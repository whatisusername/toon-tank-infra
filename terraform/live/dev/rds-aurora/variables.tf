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
# RDS
################################################################################

variable "restored_from_snapshot" {
  type        = bool
  description = "Whether the RDS cluster is restored from a snapshot."
  default     = false
}

variable "db_cluster_snapshot" {
  type = object({
    most_recent                    = optional(bool)
    db_cluster_snapshot_identifier = optional(string)
    snapshot_type                  = optional(string)
  })
  description = "Information about a DB Cluster Snapshot."
  default = {
    db_cluster_snapshot_identifier = "final-toontank-dev"
    snapshot_type                  = "manual"
  }
}

variable "database_name" {
  type        = string
  description = "Name for an automatically created database on cluster creation."
  default     = "user"
}

variable "engine_lifecycle_support" {
  type        = bool
  description = "The life cycle type for this DB instance."
  default     = false
}

variable "db_master_username" {
  type        = string
  description = "Username for the master DB user."
  default     = "admin"
}

variable "backup_window" {
  type        = string
  description = "Daily time range during which automated backups are created, in (UTC)."
  default     = "01:00-01:30"
}

variable "maintenance_window" {
  type        = string
  description = "Weekly time range during which system maintenance can occur, in (UTC)."
  default     = "Mon:00:00-Mon:00:30"
}
