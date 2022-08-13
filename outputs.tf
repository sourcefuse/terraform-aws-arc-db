################################################################################
## aurora
################################################################################
output "name" {
  value       = try(module.aurora_cluster[0].database_name, null)
  description = "Database name"
}

output "master_username" {
  value       = try(module.aurora_cluster[0].master_username, null)
  description = "Username for the master DB user"
}

output "cluster_identifier" {
  value       = try(module.aurora_cluster[0].cluster_identifier, null)
  description = "Cluster Identifier"
}

output "arn" {
  value       = try(module.aurora_cluster[0].arn, null)
  description = "Amazon Resource Name (ARN) of cluster"
}

output "endpoint" {
  value       = try(module.aurora_cluster[0].endpoint, null)
  description = "The DNS address of the RDS instance"
}

output "reader_endpoint" {
  value       = try(module.aurora_cluster[0].reader_endpoint, null)
  description = "A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas"
}

output "master_host" {
  value       = try(module.aurora_cluster[0].master_host, null)
  description = "DB Master hostname"
}

output "replicas_host" {
  value       = try(module.aurora_cluster[0].replicas_host, null)
  description = "Replicas hostname"
}

################################################################################
## rds
################################################################################
// TODO - add rds outputs
