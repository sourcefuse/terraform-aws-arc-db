################################################################################
## lookups
################################################################################
data "aws_partition" "this" {}

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

  name          = "alias/${local.rds_instance_name}"
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

  length           = 41
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

  length           = var.rds_random_admin_password_length
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
  source = "git::https://github.com/cloudposse/terraform-aws-rds-cluster.git?ref=1.7.0"
  count  = var.aurora_cluster_enabled == true ? 1 : 0

  name = local.aurora_cluster_name

  engine                      = var.aurora_engine
  engine_mode                 = var.aurora_engine_mode
  allow_major_version_upgrade = var.aurora_allow_major_version_upgrade
  auto_minor_version_upgrade  = var.aurora_auto_minor_version_upgrade
  engine_version              = var.aurora_engine_version
  cluster_family              = var.aurora_cluster_family
  cluster_size                = var.aurora_cluster_size

  admin_user     = var.aurora_db_admin_username
  admin_password = var.aurora_db_admin_password != "" ? var.aurora_db_admin_password : random_password.aurora_db_admin_password[0].result
  db_name        = var.aurora_db_name
  instance_type  = var.aurora_instance_type
  db_port        = var.aurora_db_port

  vpc_id                              = var.vpc_id
  security_groups                     = var.aurora_security_groups
  allowed_cidr_blocks                 = var.aurora_allowed_cidr_blocks
  subnets                             = var.aurora_subnets
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  storage_encrypted     = true
  storage_type          = var.aurora_storage_type
  iops                  = var.aurora_iops
  copy_tags_to_snapshot = true
  # enable monitoring every 30 seconds
  rds_monitoring_interval = 30

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_enabled ? coalesce(var.performance_insights_kms_key_id, aws_kms_key.aurora_cluster_kms_key[0].arn) : ""
  performance_insights_retention_period = var.performance_insights_retention_period

  vpc_security_group_ids = var.vpc_security_group_ids
  kms_key_arn            = var.kms_key_arn

  # reference iam role created above
  rds_monitoring_role_arn = aws_iam_role.enhanced_monitoring.arn

  scaling_configuration = var.aurora_scaling_configuration

  serverlessv2_scaling_configuration = var.aurora_serverlessv2_scaling_configuration

  tags = merge(var.tags, tomap({
    Name        = var.aurora_cluster_name
    Namespace   = var.namespace
    Environment = var.environment
    Stage       = var.environment
  }))
}

resource "aws_security_group_rule" "additional_ingress_rules_aurora" {
  for_each = { for rule in var.additional_ingress_rules_aurora : rule.name => rule }

  security_group_id = module.aurora_cluster[0].security_group_id
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
}

################################################################################
## s3 db management
################################################################################
module "db_management" {
  source = "git::https://github.com/cloudposse/terraform-aws-s3-bucket?ref=3.0.0"
  count  = var.rds_enable_custom_option_group == true ? 1 : 0

  name = "${local.rds_instance_name}-db-management"

  acl                = "private"
  enabled            = true
  user_enabled       = false
  versioning_enabled = true
  bucket_key_enabled = true
  kms_master_key_arn = "arn:${data.aws_partition.this.partition}:kms:${var.region}:${var.account_id}:alias/aws/s3"
  sse_algorithm      = "aws:kms"

  tags = merge(var.tags, tomap({
    Namespace   = var.namespace
    Environment = var.environment
    Stage       = var.environment
  }))
}

################################################################################
## option group
################################################################################
resource "aws_iam_role" "option_group" {
  count = var.rds_enable_custom_option_group == true ? 1 : 0

  name_prefix = "${var.namespace}-${var.environment}-${var.rds_instance_name}-"

  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow"
          Action = "sts:AssumeRole",
          Principal = {
            Service = "rds.amazonaws.com"
          },
        },
      ]
    }
  )
}

resource "aws_iam_policy" "option_group" {
  count = var.rds_enable_custom_option_group == true ? 1 : 0

  name_prefix = "${local.rds_instance_name}-"

  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "kms:DescribeKey",
            "kms:GenerateDataKey",
            "kms:Encrypt",
            "kms:Decrypt"
          ],
          Resource = local.instance_kms_id
        },
        {
          Effect = "Allow",
          Action = [
            "kms:DescribeKey",
            "kms:GenerateDataKey",
            "kms:Encrypt",
            "kms:Decrypt"
          ],
          Resource = local.s3_kms_alias
        },
        {
          Effect = "Allow",
          Action = [
            "s3:ListBucket",
            "s3:GetBucketLocation"
          ],
          Resource = module.db_management[0].bucket_arn
        },
        {
          Effect = "Allow",
          Action = [
            "s3:GetObjectAttributes",
            "s3:GetObject",
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:ListMultipartUploadParts",
            "s3:AbortMultipartUpload"
          ],
          Resource = "${module.db_management[0].bucket_arn}/*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "option_group" {
  count = var.rds_enable_custom_option_group == true ? 1 : 0

  role       = aws_iam_role.option_group[0].name
  policy_arn = aws_iam_policy.option_group[0].arn
}

resource "aws_db_option_group" "this" {
  count = var.rds_enable_custom_option_group == true ? 1 : 0

  name                     = "${local.rds_instance_name}-option-group"
  option_group_description = "${local.rds_instance_name} Custom Option Group"
  engine_name              = var.rds_instance_engine
  major_engine_version     = var.rds_instance_major_engine_version

  // TODO - add loop for more options
  dynamic "option" {
    for_each = var.rds_enable_custom_option_group == true && length(regexall("mariadb", var.rds_instance_engine)) == 0 ? [1] : [] // mariadb doesn't support this option

    content {
      option_name                    = length(regexall("sqlserver", var.rds_instance_engine)) > 0 ? "SQLSERVER_BACKUP_RESTORE" : "S3_INTEGRATION"
      db_security_group_memberships  = [] // TODO - make variable
      vpc_security_group_memberships = [] // TODO - make variable
      port                           = 0  // TODO - make variable
      # version                        = "1.0" // TODO - make variable

      // Only include the version attribute for S3_INTEGRATION
      version = length(regexall("sqlserver", var.rds_instance_engine)) > 0 ? null : "1.0"

      dynamic "option_settings" {
        for_each = length(regexall("sqlserver", var.rds_instance_engine)) > 0 ? [1] : []

        content {
          name  = "IAM_ROLE_ARN"
          value = try(aws_iam_role.option_group[0].arn, "")
        }
      }
    }
  }

  tags = merge(var.tags, tomap({
    Name = "${local.rds_instance_name}-option-group"
  }))
}

resource "aws_db_instance_role_association" "this" {
  count = var.rds_enable_custom_option_group && length(regexall("oracle", var.rds_instance_engine)) > 0 ? 1 : 0 // mariadb doesn't support this option

  db_instance_identifier = module.rds_instance[0].instance_id
  feature_name           = "S3_INTEGRATION"
  role_arn               = aws_iam_role.option_group[0].arn
}

################################################################################
## rds
################################################################################
module "rds_instance" {
  count  = var.rds_instance_enabled == true ? 1 : 0
  source = "git::https://github.com/cloudposse/terraform-aws-rds?ref=0.40.0"

  name = local.rds_instance_name

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
  iops                = var.rds_instance_iops
  #  monitoring_role_arn = aws_iam_role.enhanced_monitoring.arn  // TODO - make this conditional

  kms_key_arn                         = var.rds_instance_storage_encrypted == false ? "" : var.rds_kms_key_arn_override != "" ? var.rds_kms_key_arn_override : aws_kms_key.rds_db_kms_key[0].arn
  database_name                       = var.rds_instance_database_name
  database_user                       = var.rds_instance_database_user
  database_password                   = var.rds_instance_database_password != "" ? var.rds_instance_database_password : random_password.rds_db_admin_password[0].result
  database_port                       = var.rds_instance_database_port
  engine                              = var.rds_instance_engine
  engine_version                      = var.rds_instance_engine_version
  major_engine_version                = var.rds_instance_major_engine_version
  parameter_group_name                = var.rds_instance_db_parameter_group
  db_parameter_group                  = var.rds_instance_db_parameter_group
  db_parameter                        = var.rds_instance_db_parameter
  db_options                          = var.rds_instance_db_options
  option_group_name                   = local.rds_instance_option_group_name
  ca_cert_identifier                  = var.rds_instance_ca_cert_identifier
  publicly_accessible                 = var.rds_instance_publicly_accessible
  snapshot_identifier                 = var.rds_instance_snapshot_identifier
  auto_minor_version_upgrade          = var.rds_instance_auto_minor_version_upgrade
  allow_major_version_upgrade         = var.rds_instance_allow_major_version_upgrade
  apply_immediately                   = var.rds_instance_apply_immediately
  maintenance_window                  = var.rds_instance_maintenance_window
  skip_final_snapshot                 = var.rds_instance_skip_final_snapshot
  copy_tags_to_snapshot               = var.rds_instance_copy_tags_to_snapshot
  backup_retention_period             = var.rds_instance_backup_retention_period
  backup_window                       = var.rds_instance_backup_window
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  timeouts                            = var.timeouts

  tags = merge(var.tags, tomap({
    Namespace   = var.namespace
    Environment = var.environment
    Stage       = var.environment
  }))
}


resource "aws_security_group_rule" "additional_ingress_rules_rds" {
  for_each = { for rule in var.additional_ingress_rules_rds : rule.name => rule }

  security_group_id = module.rds_instance[0].security_group_id
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
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
