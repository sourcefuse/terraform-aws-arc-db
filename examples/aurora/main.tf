################################################################################
## defaults
################################################################################
terraform {
  required_version = "~> 1.3, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0, < 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "aurora" {
  source = "../../"

  environment = var.environment
  namespace   = var.namespace
  vpc_id      = data.aws_vpc.vpc.id

  name           = "${var.namespace}-${var.environment}-test"
  engine_type    = "cluster"
  port           = 5432
  username       = "postgres"
  engine         = "aurora-postgresql"
  engine_version = "16.2"

  license_model = "postgresql-license"
  rds_cluster_instances = [
    {
      instance_class          = "db.t3.medium"
      db_parameter_group_name = "default.aurora-postgresql16"
      apply_immediately       = true
      promotion_tier          = 1
    }
  ]

  db_subnet_group_data = {
    name        = "${var.namespace}-${var.environment}-subnet-group"
    create      = true
    description = "Subnet group for rds instance"
    subnet_ids  = data.aws_subnets.private.ids
  }

  performance_insights_enabled = true

  kms_data = {
    create                  = true
    description             = "KMS for Performance insight and storage"
    deletion_window_in_days = 7
    enable_key_rotation     = true
  }
}
