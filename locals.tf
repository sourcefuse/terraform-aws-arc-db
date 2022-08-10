
locals {
  ssm_params = [
    {
      name  = "/${var.namespace}/${var.environment}/primary_cluster/cluster_admin_db_password"
      value = random_password.aurora_db_admin_password.result
      type  = "SecureString"
    },
    {
      name  = "/${var.namespace}/${var.environment}/primary_cluster/cluster_admin_db_username"
      value = var.aurora_db_admin_username
      type  = "SecureString"
    },
    {
      name  = "/${var.namespace}/${var.environment}/primary_cluster/cluster_endpoint"
      value = module.rds_cluster_aurora.endpoint
      type  = "SecureString"
    }
  ]
  ssm_tags = {
    Name = "${var.namespace}-${var.environment}-db-cluster-ssm-param"
  }
}
