locals {
  prefix                             = "${var.namespace}-${var.environment}"
  security_group_ids_to_attach       = var.security_group_data.create ? concat(var.security_group_data.security_group_ids_to_attach, [module.security_group[0].id]) : var.security_group_data.security_group_ids_to_attach
  proxy_security_group_ids_to_attach = var.proxy_config.security_group_data.create ? concat(var.proxy_config.security_group_data.security_group_ids_to_attach, [module.proxy_security_group[0].id]) : var.proxy_config.security_group_data.security_group_ids_to_attach
  secret_arn                         = var.manage_user_password == true ? (var.engine_type == "rds" ? aws_db_instance.this[0].master_user_secret[0].secret_arn : aws_rds_cluster.this[0].master_user_secret[0].secret_arn) : (var.proxy_config.create ? aws_secretsmanager_secret.this[0].arn : null)

  additional_secret_arn_list = [for auth in var.proxy_config.additional_auth_list : auth.secret_arn if auth.secret_arn != null]

  secret_arn_list = concat([local.secret_arn], local.additional_secret_arn_list)

  // Adds inbound rule to RDS , so that proxy will be able to connect to RDS instance/cluster
  db_ingress_rules = var.proxy_config.create ? concat(var.security_group_data.ingress_rules,
    [
      {
        description              = "Allow traffic from RDS Proxy security group"
        source_security_group_id = module.proxy_security_group[0].id
        from_port                = var.port
        ip_protocol              = "tcp"
        to_port                  = var.port
      }
    ]
  ) : var.security_group_data.ingress_rules


  username = var.engine_type == "rds" ? aws_db_instance.this[0].username : aws_rds_cluster.this[0].master_username
  password = var.engine_type == "rds" ? aws_db_instance.this[0].password : aws_rds_cluster.this[0].master_password
  database = var.engine_type == "rds" ? aws_db_instance.this[0].db_name : aws_rds_cluster.this[0].database_name
  port     = var.engine_type == "rds" ? aws_db_instance.this[0].port : aws_rds_cluster.this[0].port

  kms_key_id                      = var.kms_data.create ? aws_kms_alias.this[0].target_key_arn : (var.kms_data.kms_key_id == null ? data.aws_kms_alias.rds.target_key_arn : var.kms_data.kms_key_id)
  performance_insights_kms_key_id = var.kms_data.create ? aws_kms_alias.this[0].target_key_arn : (var.kms_data.performance_insights_kms_key_id == null ? data.aws_kms_alias.rds.target_key_arn : var.kms_data.performance_insights_kms_key_id)
  monitoring_role_arn             = var.monitoring_interval > 0 ? (var.monitoring_role_arn == null ? aws_iam_role.enhanced_monitoring[0].arn : var.monitoring_role_arn) : null
  endpoint                        = var.engine_type == "rds" ? aws_db_instance.this[0].endpoint : aws_rds_cluster.this[0].endpoint
}
