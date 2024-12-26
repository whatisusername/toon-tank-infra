################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster"
  value       = module.aurora_mysql.cluster_arn
}

output "cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = module.aurora_mysql.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "A read-only endpoint for the cluster, automatically load-balanced across replicas"
  value       = module.aurora_mysql.cluster_reader_endpoint
}

output "cluster_port" {
  description = "The database port"
  value       = module.aurora_mysql.cluster_port
}

################################################################################
# Cluster Instance(s)
################################################################################

output "cluster_instances" {
  description = "A map of cluster instances and their attributes"
  value       = module.aurora_mysql.cluster_instances
}

################################################################################
# CloudWatch Log Group
################################################################################

output "db_cluster_cloudwatch_log_groups" {
  description = "Map of CloudWatch log groups created and their attributes"
  value       = module.aurora_mysql.db_cluster_cloudwatch_log_groups
}
