################################################################################
## defaults
################################################################################
terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

################################################################################
## lookups
################################################################################
data "aws_caller_identity" "this" {}

################################################################################
## db
################################################################################
## aurora cluster
module "aurora" {
  source = "../"
  # version     = "2.0.3"
  environment = var.environment
  namespace   = var.namespace
  region      = var.region
  vpc_id      = data.aws_vpc.vpc.id

  aurora_cluster_enabled                = true
  aurora_cluster_name                   = "aurora-example"
  enhanced_monitoring_name              = "aurora-example-enhanced-monitoring"
  aurora_db_admin_username              = "example_db_admin"
  aurora_db_name                        = "example"
  aurora_allow_major_version_upgrade    = true
  aurora_auto_minor_version_upgrade     = true
  aurora_cluster_size                   = 1
  aurora_instance_type                  = "db.t3.medium"
  aurora_subnets                        = data.aws_subnets.private.ids
  aurora_security_groups                = data.aws_security_groups.db_sg.ids
  aurora_allowed_cidr_blocks            = [data.aws_vpc.vpc.cidr_block]
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  performance_insights_kms_key_id       = data.aws_kms_alias.aurora_cluster_kms_arn.target_key_arn
  kms_key_arn                           = data.aws_kms_alias.aurora_cluster_kms_arn.target_key_arn
  iam_database_authentication_enabled   = true
  additional_rules                      = var.additional_rules
}

## sql server rds instance
module "rds_sql_server" {
  source      = "sourcefuse/arc-db/aws"
  version     = "2.0.3"
  environment = var.environment
  namespace   = var.namespace
  region      = var.region
  vpc_id      = data.aws_vpc.vpc.id

  account_id                               = data.aws_caller_identity.this.id
  rds_instance_enabled                     = true
  rds_instance_name                        = "sql-server-example"
  enhanced_monitoring_name                 = "sql-server-example-enhanced-monitoring"
  rds_instance_dns_zone_id                 = ""
  rds_instance_host_name                   = ""
  rds_instance_database_name               = null // sql server database name must be null
  rds_instance_database_user               = "example_db_admin"
  rds_instance_database_port               = 1433
  rds_instance_engine                      = "sqlserver-ex" // express edition.
  rds_instance_engine_version              = "15.00.4236.7.v1"
  rds_instance_major_engine_version        = "15.00"
  rds_instance_db_parameter_group          = "default.sqlserver-ex-15.0"
  rds_instance_db_parameter                = []
  rds_instance_db_options                  = []
  rds_enable_custom_option_group           = true
  rds_instance_ca_cert_identifier          = "rds-ca-2019"
  rds_instance_publicly_accessible         = false
  rds_instance_multi_az                    = false
  rds_instance_storage_type                = "gp2"
  rds_instance_instance_class              = "db.t3.small"
  rds_instance_allocated_storage           = 25
  rds_instance_storage_encrypted           = false // sql server express doesn't support encryption at rest
  rds_instance_snapshot_identifier         = null
  rds_instance_auto_minor_version_upgrade  = true
  rds_instance_allow_major_version_upgrade = true
  rds_instance_apply_immediately           = true
  rds_instance_maintenance_window          = "Mon:00:00-Mon:02:00"
  rds_instance_skip_final_snapshot         = true
  rds_instance_copy_tags_to_snapshot       = true
  rds_instance_backup_retention_period     = 3
  rds_instance_backup_window               = "22:00-23:59"
  rds_instance_security_group_ids          = data.aws_security_groups.db_sg.ids
  rds_instance_allowed_cidr_blocks         = [data.aws_vpc.vpc.cidr_block]
  rds_instance_subnet_ids                  = data.aws_subnets.private.ids
}
