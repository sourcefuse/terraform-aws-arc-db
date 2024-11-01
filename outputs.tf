output "id" {
  value       = var.engine_type == "rds" ? aws_db_instance.this[0].id : aws_rds_cluster.this[0].id
  description = "Instance or Cluster ID"
}

output "identifier" {
  value       = var.engine_type == "rds" ? aws_db_instance.this[0].id : aws_rds_cluster.this[0].id
  description = "Instance or Cluster Identifier "
}

output "arn" {
  value       = var.engine_type == "rds" ? aws_db_instance.this[0].arn : aws_rds_cluster.this[0].arn
  description = "Instance or Cluster ARN"
}

output "username" {
  value       = local.username
  description = "Username for the Database"
}

output "database" {
  value       = local.database
  description = "database name"
}

output "port" {
  value       = local.port
  description = "Dtabase server port"
}

output "endpoint" {
  value       = var.engine_type == "rds" ? aws_db_instance.this[0].endpoint : aws_rds_cluster.this[0].endpoint
  description = "Instance or Cluster Endpoint"
}

output "kms_key_id" {
  value       = local.kms_key_id
  description = "Instance or Cluster KM Key ID"
}

output "performance_insights_kms_key_id" {
  value       = local.performance_insights_kms_key_id
  description = "Instance or Cluster Performance insight KM Key ID"
}

output "monitoring_role_arn" {
  value       = local.monitoring_role_arn
  description = "Instance or Cluster Monitoring role arn"
}
