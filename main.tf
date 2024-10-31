################################################################################
## RDS instance
################################################################################
resource "aws_db_instance" "this" {
  identifier               = var.name
  db_name                  = var.database_name
  allocated_storage        = var.allocated_storage
  engine                   = var.engine
  engine_version           = var.engine_version
  engine_lifecycle_support = var.engine_lifecycle_support
  port                     = var.port
  instance_class           = var.instance_class


  username                    = var.username
  password                    = var.password == null && var.manage_user_password == false ? random_password.master[0].result : var.password
  manage_master_user_password = var.manage_user_password

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
  performance_insights_kms_key_id       = var.kms_data.create ? aws_kms_alias.this[0].target_key_arn : (var.kms_data.performance_insights_kms_key_id == null ? data.aws_kms_alias.rds.target_key_arn : var.performance_insights_kms_key_id)
  performance_insights_retention_period = var.performance_insights_retention_period
  enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_interval > 0 ? (var.monitoring_role_arn == null ? aws_iam_role.enhanced_monitoring[0].arn : var.monitoring_role_arn) : null

  license_model     = var.license_model
  apply_immediately = var.apply_immediately
  tags              = var.tags
}
