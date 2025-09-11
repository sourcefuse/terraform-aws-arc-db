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

module "rds" {
  source = "../../"

  environment = var.environment
  namespace   = var.namespace
  vpc_id      = data.aws_vpc.this.id

  name            = "${var.namespace}-${var.environment}-test-01-from-snapshot"
  engine_type     = "rds"
  db_server_class = "db.t3.small"
  port            = 5432

  # 🔹 Restore from snapshot
  snapshot_identifier = "manual-snaphost-test01" ### get this using Data block

  # 🔹 Skip values that don’t apply when restoring from snapshot
  engine               = null
  engine_version       = null
  username             = null
  manage_user_password = false

  license_model = "postgresql-license"

  db_subnet_group_data = {
    name        = "${var.namespace}-${var.environment}-subnet-group"
    create      = true
    description = "Subnet group for rds instance"
    subnet_ids  = data.aws_subnets.private.ids
  }

  security_group_data          = local.rds_security_group_data
  performance_insights_enabled = true
  monitoring_interval          = 5

}
