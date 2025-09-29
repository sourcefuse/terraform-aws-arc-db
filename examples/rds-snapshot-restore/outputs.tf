output "db_instance_id" {
  description = "The RDS instance ID"
  value       = module.rds_from_snapshot.id
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = module.rds_from_snapshot.arn
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = module.rds_from_snapshot.endpoint
}

output "db_instance_port" {
  description = "The database port"
  value       = module.rds_from_snapshot.port
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = module.rds_from_snapshot.username
  sensitive   = true
}

output "db_instance_database_name" {
  description = "The database name"
  value       = module.rds_from_snapshot.database
}

output "kms_key_id" {
  description = "The KMS key ID used for encryption"
  value       = module.rds_from_snapshot.kms_key_id
}