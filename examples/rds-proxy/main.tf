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

  proxy_security_group_data = {
    create      = true
    description = "Security Group for RDS Proxy"

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


  parameter_group_config = {
    create = true
    family = "postgres16"
    parameters = {
      "paramter-1" = {
        name  = "log_connections"
        value = "1"
    } }
  }

}

module "rds" {
  source = "../../"

  environment = var.environment
  namespace   = var.namespace
  vpc_id      = data.aws_vpc.vpc.id

  name            = "${var.namespace}-${var.environment}-test-proxy-2"
  engine_type     = "rds"
  db_server_class = "db.t3.small"
  port            = 5432
  username        = "postgres"
  engine          = "postgres"
  engine_version  = "16.3"

  monitoring_interval = 60
  license_model       = "postgresql-license"
  db_subnet_group_data = {
    name        = "${var.namespace}-${var.environment}-subnet-group-proxy"
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

  parameter_group_config = local.parameter_group_config
  security_group_data    = local.rds_security_group_data

  proxy_config = {
    create                   = true
    engine_family            = "POSTGRESQL"
    vpc_subnet_ids           = data.aws_subnets.private.ids
    security_group_data      = local.proxy_security_group_data
    require_tls              = true
    debug_logging            = true
    idle_client_timeout_secs = 3600 # 1 hour

    auth = {
      auth_scheme               = "SECRETS"
      description               = "Authentication for RDS Proxy"
      iam_auth                  = "DISABLED" // REQUIRED
      client_password_auth_type = "POSTGRES_SCRAM_SHA_256"
    }

    additional_auth_list = []

    connection_pool_config = {
      max_connections_percent      = 100
      max_idle_connections_percent = 50
    }
  }
}
