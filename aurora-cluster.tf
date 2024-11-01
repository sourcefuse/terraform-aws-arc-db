resource "random_password" "master" {
  count = var.password == null && var.manage_user_password == null ? 1 : 0

  length           = 41
  special          = true
  override_special = "!#*^"

  lifecycle {
    ignore_changes = [
      length,
      lower,
      min_lower,
      min_numeric,
      min_special,
      min_upper,
      override_special,
      special,
      upper
    ]
  }
}

resource "aws_rds_cluster" "this" {
  count = var.engine_type == "cluster" ? 1 : 0

  cluster_identifier                  = var.name
  engine                              = var.engine
  engine_version                      = var.engine_version
  engine_mode                         = var.engine_mode == "serverless" ? "provisioned" : var.engine_mode
  port                                = var.port
  master_username                     = var.username
  master_password                     = var.password == null && var.manage_user_password == null ? random_password.master[0].result : var.password
  manage_master_user_password         = var.manage_user_password
  database_name                       = var.database_name
  db_cluster_instance_class           = strcontains(var.engine, "aurora") ? null : var.db_server_class
  vpc_security_group_ids              = local.security_group_ids_to_attach
  db_subnet_group_name                = var.db_subnet_group_data.name
  db_cluster_parameter_group_name     = var.db_cluster_parameter_group_name
  db_instance_parameter_group_name    = var.db_instance_parameter_group_name
  allocated_storage                   = strcontains(var.engine, "aurora") ? null : var.allocated_storage
  backup_retention_period             = var.backup_retention_period
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  storage_encrypted                   = var.storage_encrypted
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  storage_type                        = var.storage_type
  ca_certificate_identifier           = var.ca_certificate_identifier
  kms_key_id                          = var.kms_data.create ? aws_kms_alias.this[0].target_key_arn : (var.kms_data.kms_key_id == null ? data.aws_kms_alias.rds.target_key_arn : var.kms_data.kms_key_id)
  performance_insights_enabled        = var.performance_insights_enabled
  performance_insights_kms_key_id     = var.kms_data.create ? aws_kms_alias.this[0].target_key_arn : (var.kms_data.performance_insights_kms_key_id == null ? data.aws_kms_alias.rds.target_key_arn : var.kms_data.performance_insights_kms_key_id)
  deletion_protection                 = var.deletion_protection
  delete_automated_backups            = var.delete_automated_backups
  skip_final_snapshot                 = var.skip_final_snapshot
  final_snapshot_identifier           = var.final_snapshot_identifier
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  engine_lifecycle_support            = var.engine_lifecycle_support
  network_type                        = var.network_type


  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.engine_mode == "serverless" ? [var.serverlessv2_scaling_config] : [] // Note :- For Serverless V2 , engine_mode should be "provisioned" but for simplecity  "serverless" is expected
    // Refer : serverless

    content {
      max_capacity = serverlessv2_scaling_configuration.value.max_capacity
      min_capacity = serverlessv2_scaling_configuration.value.max_capacity
    }

  }

  tags       = var.tags
  depends_on = [aws_db_subnet_group.this, module.security_group]
}

resource "aws_rds_cluster_instance" "this" {
  for_each = { for idx, instance in var.rds_cluster_instances : idx => instance }

  cluster_identifier = aws_rds_cluster.this[0].id
  identifier         = each.value.name != null ? each.value.name : "${aws_rds_cluster.this[0].id}-${each.key + 1}"
  instance_class     = each.value.instance_class

  engine                                = aws_rds_cluster.this[0].engine
  engine_version                        = aws_rds_cluster.this[0].engine_version
  db_subnet_group_name                  = aws_rds_cluster.this[0].db_subnet_group_name
  availability_zone                     = each.value.availability_zone
  publicly_accessible                   = each.value.publicly_accessible
  db_parameter_group_name               = each.value.db_parameter_group_name
  apply_immediately                     = var.apply_immediately
  preferred_maintenance_window          = var.preferred_maintenance_window
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  ca_cert_identifier                    = var.ca_cert_identifier
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_interval > 0 ? (var.monitoring_role_arn == null ? aws_iam_role.enhanced_monitoring[0].arn : var.monitoring_role_arn) : null
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.kms_data.create ? aws_kms_alias.this[0].target_key_arn : (var.kms_data.performance_insights_kms_key_id == null ? data.aws_kms_alias.rds.target_key_arn : var.kms_data.performance_insights_kms_key_id)
  performance_insights_retention_period = var.performance_insights_retention_period
  promotion_tier                        = each.value.promotion_tier
  copy_tags_to_snapshot                 = each.value.copy_tags_to_snapshot

  tags = var.tags
}
