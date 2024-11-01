output "id" {
  value       = module.rds.id
  description = "Instance or Cluster ID"
}

output "identifier" {
  value       = module.rds.identifier
  description = "Instance or Cluster Identifier"
}

output "arn" {
  value       = module.rds.arn
  description = "Instance or Cluster ARN"
}

output "username" {
  value       = module.rds.username
  description = "Username for the Database"
}

output "database" {
  value       = module.rds.database
  description = "Database name"
}

output "port" {
  value       = module.rds.port
  description = "Database server port"
}

output "endpoint" {
  value       = module.rds.endpoint
  description = "Instance or Cluster Endpoint"
}

output "kms_key_id" {
  value       = module.rds.kms_key_id
  description = "Instance or Cluster KMS Key ID"
}

output "performance_insights_kms_key_id" {
  value       = module.rds.performance_insights_kms_key_id
  description = "Instance or Cluster Performance Insights KMS Key ID"
}

output "monitoring_role_arn" {
  value       = module.rds.monitoring_role_arn
  description = "Instance or Cluster Monitoring Role ARN"
}
