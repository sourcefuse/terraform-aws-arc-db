################################################################################
## aurora
################################################################################
output "aurora_name" {
  value       = try(module.aurora_cluster[0].database_name, null)
  description = "Database name"
}

output "aurora_master_username" {
  value       = try(module.aurora_cluster[0].master_username, null)
  description = "Username for the master DB user"
}

output "aurora_cluster_identifier" {
  value       = try(module.aurora_cluster[0].cluster_identifier, null)
  description = "Cluster Identifier"
}

output "aurora_arn" {
  value       = try(module.aurora_cluster[0].arn, null)
  description = "Amazon Resource Name (ARN) of cluster"
}

output "aurora_endpoint" {
  value       = try(module.aurora_cluster[0].endpoint, null)
  description = "The DNS address of the RDS instance"
}

output "aurora_reader_endpoint" {
  value       = try(module.aurora_cluster[0].reader_endpoint, null)
  description = "A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas"
}

output "aurora_master_host" {
  value       = try(module.aurora_cluster[0].master_host, null)
  description = "DB Master hostname"
}

output "aurora_replicas_host" {
  value       = try(module.aurora_cluster[0].replicas_host, null)
  description = "Replicas hostname"
}

################################################################################
## rds
################################################################################
output "rds_instance_arn" {
  value       = try(module.rds_instance[0].instance_arn, null)
  description = "The RDS Instance AWS ARN."
}

output "rds_instance_endpoint" {
  value       = try(module.rds_instance[0].instance_endpoint, null)
  description = "The DNS address to the RDS Instance."
}

output "rds_instance_hostname" {
  value       = try(module.rds_instance[0].hostname, null)
  description = "Hostname of the RDS Instance."
}

output "rds_instance_id" {
  value       = try(module.rds_instance[0].instance_id, null)
  description = "The RDS Instance AWS ID."
}

output "rds_instance_resource_id" {
  value       = try(module.rds_instance[0].resource_id, null)
  description = "The RDS Instance AWS resource ID."
}

output "rds_instance_kms_arn" {
  value = aws_kms_key.rds_db_kms_key.arn
}

output "rds_instance_kms_id" {
  value = aws_kms_key.rds_db_kms_key.key_id
}
