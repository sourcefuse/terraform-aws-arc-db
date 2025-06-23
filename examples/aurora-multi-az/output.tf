output "id" {
  value       = module.aurora.id
  description = "Instance or Cluster ID"
}

output "identifier" {
  value       = module.aurora.identifier
  description = "Instance or Cluster Identifier"
}

output "arn" {
  value       = module.aurora.arn
  description = "Instance or Cluster ARN"
}

output "username" {
  value       = module.aurora.username
  description = "Username for the Database"
}

output "port" {
  value       = module.aurora.port
  description = "Database server port"
}

output "endpoint" {
  value       = module.aurora.endpoint
  description = "Instance or Cluster Endpoint"
}

output "kms_key_id" {
  value       = module.aurora.kms_key_id
  description = "Instance or Cluster KMS Key ID"
}

output "performance_insights_kms_key_id" {
  value       = module.aurora.performance_insights_kms_key_id
  description = "Instance or Cluster Performance Insights KMS Key ID"
}

output "master_user_secret" {
  value       = module.aurora.master_user_secret
  description = "Secret ARN"
}
