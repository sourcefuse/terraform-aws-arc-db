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

locals {
  rds_security_group_data = {
    create      = true
    description = "Security Group for RDS instance"

    ingress_rules = [
      {
        description = "Allow traffic from local network"
        cidr_block  = data.aws_vpc.vpc.cidr_block
        from_port   = 5432
        ip_protocol = "tcp"
        to_port     = 5432
      }
    ]

    egress_rules = [
      {
        description = "Allow all outbound traffic"
        cidr_block  = "0.0.0.0/0"
        from_port   = -1
        ip_protocol = "-1"
        to_port     = -1
      }
    ]
  }
}

module "rds" {
  source = "../../"

  environment = var.environment
  namespace   = var.namespace
  vpc_id      = data.aws_vpc.vpc.id

  name                 = "${var.namespace}-${var.environment}-test"
  engine_type          = "rds"
  db_server_class      = "db.t3.small"
  port                 = 5432
  username             = "postgres"
  manage_user_password = true
  engine               = "postgres"
  engine_version       = "16.3"

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

  kms_data = {
    create                  = true
    description             = "KMS for Performance insight and storage"
    deletion_window_in_days = 7
    enable_key_rotation     = true
  }
}
