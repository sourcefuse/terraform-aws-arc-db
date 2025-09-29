################################################################################
## Example: RDS PostgreSQL instance restored from snapshot
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

module "rds_from_snapshot" {
  source = "../../"

  environment = var.environment
  namespace   = var.namespace
  vpc_id      = data.aws_vpc.this.id
  name        = "${var.namespace}-${var.environment}-postgres-snapshot"
  
  # Restore from snapshot
  snapshot_identifier = var.snapshot_identifier
  
  # Engine configuration (some will be inherited from snapshot)
  engine_type    = "rds"
  engine         = "postgres"
  engine_version = var.engine_version # Optional, can inherit from snapshot
  port           = 5432
  
  # These are ignored when restoring from snapshot but still required by module
  username = "postgres"
  
  # Instance configuration
  db_server_class = var.instance_class
  allocated_storage = var.allocated_storage
  
  # License model for PostgreSQL
  license_model = "postgresql-license"
  
  # Subnet configuration
  db_subnet_group_data = {
    name        = "${var.namespace}-${var.environment}-subnet-group"
    create      = true
    description = "Subnet group for RDS instance restored from snapshot"
    subnet_ids  = data.aws_subnets.private.ids
  }
  
  # Security group configuration
  security_group_data = {
    create      = true
    description = "Security group for RDS instance restored from snapshot"
    ingress_rules = [
      {
        description              = "PostgreSQL access from VPC"
        cidr_block              = data.aws_vpc.this.cidr_block
        from_port               = 5432
        to_port                 = 5432
        ip_protocol             = "tcp"
      }
    ]
    egress_rules = [
      {
        description = "Allow all outbound"
        cidr_block  = "0.0.0.0/0"
        from_port   = 0
        to_port     = 0
        ip_protocol = "-1"
      }
    ]
  }
  
  # Performance and monitoring
  performance_insights_enabled = true
  monitoring_interval          = 60
  
  # Backup configuration
  backup_retention_period = 7
  skip_final_snapshot     = false
  final_snapshot_identifier = "${var.namespace}-${var.environment}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  # Maintenance and updates
  auto_minor_version_upgrade = true
  apply_immediately          = var.apply_immediately
  
  # Encryption (KMS key can be different from source snapshot)
  kms_data = {
    create                  = true
    description             = "KMS key for RDS instance restored from snapshot"
    deletion_window_in_days = 7
    enable_key_rotation     = true
  }
  
  tags = {
    Name        = "${var.namespace}-${var.environment}-postgres-snapshot"
    Environment = var.environment
    RestoreFrom = "snapshot"
    SnapshotId  = var.snapshot_identifier
  }
}