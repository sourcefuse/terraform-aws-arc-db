################################################################################
## RDS instance
################################################################################
################################################################################
## RDS instance
################################################################################
resource "aws_db_instance" "this" {
  count = var.engine_type == "rds" ? 1 : 0

  identifier = var.name

  # ========= Dynamic logic for snapshot vs new =========
  snapshot_identifier = var.snapshot_identifier != null ? var.snapshot_identifier : null

  # Only set these if NOT restoring from snapshot
  db_name                     = var.snapshot_identifier == null ? var.database_name : null
  username                    = var.snapshot_identifier == null ? var.username : null
  password                    = var.snapshot_identifier == null && local.manage_user_password == false ? random_password.master[0].result : (var.snapshot_identifier == null ? var.password : null)
  manage_master_user_password = var.snapshot_identifier == null ? var.manage_user_password : null
  engine                      = var.snapshot_identifier == null ? var.engine : null
  engine_version              = var.snapshot_identifier == null ? var.engine_version : null
  engine_lifecycle_support    = var.snapshot_identifier == null ? var.engine_lifecycle_support : null
  port                        = var.snapshot_identifier == null ? var.port : null
  # =====================================================

  allocated_storage                   = var.allocated_storage
  instance_class                      = var.db_server_class
  iops                                = var.iops
  db_subnet_group_name                = var.db_subnet_group_data.create ? aws_db_subnet_group.this[0].name : null
  vpc_security_group_ids              = local.security_group_ids_to_attach
  multi_az                            = var.enable_multi_az
  publicly_accessible                 = var.publicly_accessible
  storage_type                        = var.storage_type
  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  allow_major_version_upgrade         = var.allow_major_version_upgrade
  backup_retention_period             = var.backup_retention_period
  backup_window                       = var.preferred_backup_window
  maintenance_window                  = var.preferred_maintenance_window
  delete_automated_backups            = var.delete_automated_backups
  skip_final_snapshot                 = var.skip_final_snapshot
  final_snapshot_identifier           = var.final_snapshot_identifier
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  deletion_protection                 = var.deletion_protection
  ca_cert_identifier                  = var.ca_cert_identifier

  option_group_name    = var.option_group_config.create ? aws_db_option_group.this[0].name : var.option_group_config.name
  parameter_group_name = var.parameter_group_config.create ? aws_db_parameter_group.this[0].name : var.parameter_group_config.name

  storage_encrypted                     = var.storage_encrypted
  kms_key_id                            = var.kms_data.create ? aws_kms_alias.this[0].target_key_arn : (var.kms_data.kms_key_id == null ? data.aws_kms_alias.rds.target_key_arn : var.kms_data.kms_key_id)
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.kms_data.create ? aws_kms_alias.this[0].target_key_arn : (var.kms_data.performance_insights_kms_key_id == null ? data.aws_kms_alias.rds.target_key_arn : var.kms_data.performance_insights_kms_key_id)
  performance_insights_retention_period = var.performance_insights_retention_period
  enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_interval > 0 ? (var.monitoring_role_arn == null ? aws_iam_role.enhanced_monitoring[0].arn : var.monitoring_role_arn) : null

  license_model     = var.license_model
  apply_immediately = var.apply_immediately
  tags              = var.tags
}
