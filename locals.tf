
locals {

  ssm_params = [
    {
      name  = "/${var.namespace}/${var.environment}/primary_cluster/cluster_admin_db_password"
      value = random_password.db_admin_password.result
      type  = "SecureString"
    },
    {
      name  = "/${var.namespace}/${var.environment}/primary_cluster/cluster_admin_db_username"
      value = var.db_admin_username
      type  = "SecureString"
    },
    {
      name  = "/${var.namespace}/${var.environment}/primary_cluster/cluster_endpoint"
      value = module.rds_cluster_aurora_postgres.endpoint
      type  = "SecureString"
    }
  ]
  ssm_tags = { Name = "${var.namespace}-${var.environment}-db-cluster-ssm-param" }

  tags = merge(tomap({
    Creator     = "terraform"
    Environment = var.environment
    Project     = "sf_ref_arch"
    Repo        = "terraform-aws-ref-arch-db"
    Role        = "database"
  }), var.tags)
}
