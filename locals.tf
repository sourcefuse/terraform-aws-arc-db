locals {
  prefix                             = "${var.namespace}-${var.environment}"
  security_group_ids_to_attach       = var.security_group_data.create ? concat(var.security_group_data.security_group_ids_to_attach, [module.security_group[0].id]) : var.security_group_data.security_group_ids_to_attach
  proxy_security_group_ids_to_attach = var.proxy_config.security_group_data.create ? concat(var.proxy_config.security_group_data.security_group_ids_to_attach, [module.proxy_security_group[0].id]) : var.proxy_config.security_group_data.security_group_ids_to_attach
  secret_arn                         = var.manage_user_password ? aws_rds_cluster.this.master_user_secret[0].secret_arn : (var.proxy_config.create ? aws_secretsmanager_secret.this[0].arn : null)

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
}
