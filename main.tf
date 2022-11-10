################################################################################
## kms
################################################################################
## aurora
// TODO: add alarms
resource "aws_kms_key" "aurora_cluster_kms_key" {
  count = var.aurora_cluster_enabled == true ? 1 : 0

  description             = "Aurora cluster KMS key"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(var.tags, tomap({
    Name = "${var.namespace}-${var.environment}-aurora-cluster-kms-key" // TODO - add support for custom names
  }))
}

resource "aws_kms_alias" "aurora_cluster_kms_key" {
  count = var.aurora_cluster_enabled == true ? 1 : 0

  name          = "alias/${var.namespace}-${var.environment}-aurora-cluster-kms-key" // TODO - add support for custom names
  target_key_id = aws_kms_key.aurora_cluster_kms_key[0].id
}

## rds
resource "aws_kms_key" "rds_db_kms_key" {
  count = var.rds_instance_enabled == true ? 1 : 0

  description             = "RDS DB KMS key"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(var.tags, tomap({
    Name = "${var.namespace}-${var.environment}-${var.rds_instance_name}"
  }))
}

resource "aws_kms_alias" "rds_db_kms_key" {
  count = var.rds_instance_enabled == true ? 1 : 0

  name          = "alias/${var.namespace}-${var.environment}-${var.rds_instance_name}"
  target_key_id = aws_kms_key.rds_db_kms_key[0].id
}

################################################################################
## iam
################################################################################
# create IAM role for monitoring
resource "aws_iam_role" "enhanced_monitoring" {
  name               = "${var.enhanced_monitoring_name}-role"
  assume_role_policy = data.aws_iam_policy_document.enhanced_monitoring.json

  tags = merge(var.tags, tomap({
    Name = "${var.enhanced_monitoring_name}-role"
  }))
}

# Attach Amazon's managed policy for RDS enhanced monitoring
resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  role       = aws_iam_role.enhanced_monitoring.name
  policy_arn = var.enhanced_monitoring_arn
}

# allow rds to assume this role
data "aws_iam_policy_document" "enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

################################################################################
## password generation
################################################################################
## aurora
resource "random_password" "aurora_db_admin_password" {
  count = var.aurora_cluster_enabled == true ? 1 : 0

  length           = 64
  special          = true
  override_special = "!#*^"

  lifecycle {
    ignore_changes = [
      length,
      lower,
      min_lower,
      min_numeric,
      min_special,
      min_upper,
      override_special,
      special,
      upper
    ]
  }
}

## rds
resource "random_password" "rds_db_admin_password" {
  count = var.rds_instance_enabled == true ? 1 : 0

  length           = 64
  special          = true
  override_special = "!#*^"

  lifecycle {
    ignore_changes = [
      length,
      lower,
      min_lower,
      min_numeric,
      min_special,
      min_upper,
      override_special,
      special,
      upper
    ]
  }
}

################################################################################
## aurora cluster
################################################################################
module "aurora_cluster" {
  count  = var.aurora_cluster_enabled == true ? 1 : 0
  source = "git::https://github.com/cloudposse/terraform-aws-rds-cluster.git?ref=0.46.2"

  name      = var.aurora_cluster_name
  namespace = var.namespace
  stage     = var.environment

  engine                      = var.aurora_engine
  engine_mode                 = var.aurora_engine_mode
  allow_major_version_upgrade = var.aurora_allow_major_version_upgrade
  auto_minor_version_upgrade  = var.aurora_auto_minor_version_upgrade
  engine_version              = var.aurora_engine_version
  cluster_family              = var.aurora_cluster_family
  cluster_size                = var.aurora_cluster_size

  admin_user     = var.aurora_db_admin_username
  admin_password = var.aurora_db_admin_password ? var.aurora_db_admin_password != "" : random_password.aurora_db_admin_password[0].result
  db_name        = var.aurora_db_name
  instance_type  = var.aurora_instance_type
  db_port        = 5432

  vpc_id              = var.vpc_id
  security_groups     = var.aurora_security_groups
  allowed_cidr_blocks = var.aurora_allowed_cidr_blocks
  subnets             = var.aurora_subnets

  storage_encrypted     = true
  copy_tags_to_snapshot = true
  # enable monitoring every 30 seconds
  rds_monitoring_interval = 30

  # reference iam role created above
  # TODO: make scaling config variable
  rds_monitoring_role_arn = aws_iam_role.enhanced_monitoring.arn
  scaling_configuration = [{
    auto_pause               = true
    max_capacity             = 16
    min_capacity             = 2
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }]

  tags = merge(var.tags, tomap({
    Name = var.aurora_cluster_name
  }))
}

################################################################################
## rds
################################################################################
module "rds_instance" {
  count  = var.rds_instance_enabled == true ? 1 : 0
  source = "git::https://github.com/cloudposse/terraform-aws-rds?ref=0.38.8"

  stage               = var.environment
  name                = var.rds_instance_name
  namespace           = var.namespace
  dns_zone_id         = var.rds_instance_dns_zone_id
  host_name           = var.rds_instance_host_name
  vpc_id              = var.vpc_id
  multi_az            = var.rds_instance_multi_az
  storage_type        = var.rds_instance_storage_type
  instance_class      = var.rds_instance_instance_class
  allocated_storage   = var.rds_instance_allocated_storage
  storage_encrypted   = var.rds_instance_storage_encrypted
  security_group_ids  = var.rds_instance_security_group_ids
  allowed_cidr_blocks = var.rds_instance_allowed_cidr_blocks
  subnet_ids          = var.rds_instance_subnet_ids
  license_model       = var.rds_instance_license_model
  deletion_protection = var.deletion_protection

  kms_key_arn                 = var.rds_kms_key_arn_override != "" ? var.rds_kms_key_arn_override : aws_kms_key.rds_db_kms_key[0].arn
  database_name               = var.rds_instance_database_name
  database_user               = var.rds_instance_database_user
  database_password           = var.rds_instance_database_password != "" ? var.rds_instance_database_password : random_password.rds_db_admin_password[0].result
  database_port               = var.rds_instance_database_port
  engine                      = var.rds_instance_engine
  engine_version              = var.rds_instance_engine_version
  major_engine_version        = var.rds_instance_major_engine_version
  db_parameter_group          = var.rds_instance_db_parameter_group
  db_parameter                = var.rds_instance_db_parameter
  db_options                  = var.rds_instance_db_options
  option_group_name           = var.rds_instance_option_group_name
  ca_cert_identifier          = var.rds_instance_ca_cert_identifier
  publicly_accessible         = var.rds_instance_publicly_accessible
  snapshot_identifier         = var.rds_instance_snapshot_identifier
  auto_minor_version_upgrade  = var.rds_instance_auto_minor_version_upgrade
  allow_major_version_upgrade = var.rds_instance_allow_major_version_upgrade
  apply_immediately           = var.rds_instance_apply_immediately
  maintenance_window          = var.rds_instance_maintenance_window
  skip_final_snapshot         = var.rds_instance_skip_final_snapshot
  copy_tags_to_snapshot       = var.rds_instance_copy_tags_to_snapshot
  backup_retention_period     = var.rds_instance_backup_retention_period
  backup_window               = var.rds_instance_backup_window

  tags = merge(var.tags, tomap({
    Name = "${var.namespace}-${var.environment}-${var.rds_instance_name}"
  }))
}

################################################################################
## ssm parameters
################################################################################
resource "aws_ssm_parameter" "this" {
  for_each = { for x in local.ssm_params : x.name => x }

  name        = lookup(each.value, "name", null)
  value       = lookup(each.value, "value", null)
  description = lookup(each.value, "description", "Managed by Terraform")
  type        = lookup(each.value, "type", null)
  overwrite   = lookup(each.value, "overwrite", true)

  tags = merge(var.tags, local.ssm_tags)
}
