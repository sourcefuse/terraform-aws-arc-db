locals {
  // TODO - improve this better when "enabled" conditions are false
  ssm_params = try([
    {
      name  = "/${var.namespace}/${var.environment}/primary_cluster/cluster_admin_db_password"
      value = random_password.aurora_db_admin_password[0].result
      type  = "SecureString"
    },
    {
      name  = "/${var.namespace}/${var.environment}/primary_cluster/cluster_admin_db_username"
      value = var.aurora_db_admin_username
      type  = "SecureString"
    },
    {
      name  = "/${var.namespace}/${var.environment}/primary_cluster/cluster_endpoint"
      value = module.aurora_cluster[0].endpoint
      type  = "SecureString"
    }
  ], [])

  ssm_tags = {
    Name = "${var.namespace}-${var.environment}-db-cluster-ssm-param"
  }
}
