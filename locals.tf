locals {
  ## aurora
  aurora_ssm_params = var.aurora_cluster_enabled == true ? [
    {
      name  = "/${var.namespace}/${var.environment}/${var.aurora_cluster_name}/cluster_admin_db_password"
      value = random_password.aurora_db_admin_password[0].result
      type  = "SecureString"
    },
    {
      name  = "/${var.namespace}/${var.environment}/${var.aurora_cluster_name}/cluster_admin_db_username"
      value = var.aurora_db_admin_username
      type  = "SecureString"
    },
    {
      name  = "/${var.namespace}/${var.environment}/${var.aurora_cluster_name}/cluster_endpoint"
      value = module.aurora_cluster[0].endpoint
      type  = "SecureString"
    }
  ] : []

  aurora_ssm_tags = var.aurora_cluster_enabled == true ? {
    AuroraName = "${var.namespace}-${var.environment}-db-cluster-ssm-param"
  } : {}

  ## rds
  rds_instance_ssm_params = var.rds_instance_enabled == true ? [
    {
      name  = "/${var.namespace}/${var.environment}/${var.rds_instance_name}/admin_db_password"
      value = random_password.rds_db_admin_password[0].result
      type  = "SecureString"
    },
    {
      name  = "/${var.namespace}/${var.environment}/${var.rds_instance_name}/admin_db_username"
      value = var.rds_instance_database_user
      type  = "SecureString"
    },
    {
      name  = "/${var.namespace}/${var.environment}/${var.rds_instance_name}/endpoint"
      value = module.rds_instance[0].instance_endpoint
      type  = "SecureString"
    }
  ] : []

  rds_instance_ssm_tags = var.rds_instance_enabled == true ? {
    RDSName = "${var.namespace}-${var.environment}-rds-instance-ssm-param"
  } : {}

  ## concat locals
  ssm_params = concat(
    local.aurora_ssm_params,
    local.rds_instance_ssm_params,
  )

  ssm_tags = merge(
    local.aurora_ssm_tags,
    local.rds_instance_ssm_tags,
  )
}
