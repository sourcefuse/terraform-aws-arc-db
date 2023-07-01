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

data "aws_kms_alias" "rds" {
  name = "alias/aws/rds"
}

################################################################################
## aurora cluster
################################################################################
module "aurora_cluster" {
  source = "git::https://github.com/cloudposse/terraform-aws-rds-cluster.git?ref=1.3.2"
  count  = var.aurora_cluster_enabled == true ? 1 : 0

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
  copy_tags_to_snapshot = true
  # enable monitoring every 30 seconds
  rds_monitoring_interval = 30

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_enabled ? data.aws_kms_alias.rds.id : ""
  performance_insights_retention_period = var.performance_insights_retention_period

  vpc_security_group_ids = var.vpc_security_group_ids
  kms_key_arn            = var.kms_key_arn


  # reference iam role created above
  rds_monitoring_role_arn = aws_iam_role.enhanced_monitoring.arn

  scaling_configuration = var.aurora_scaling_configuration

  serverlessv2_scaling_configuration = var.aurora_serverlessv2_scaling_configuration

  tags = merge(var.tags, tomap({
    Name = var.aurora_cluster_name
  }))
}

################################################################################
## s3 db management
################################################################################
module "db_management" {
  source = "git::https://github.com/cloudposse/terraform-aws-s3-bucket?ref=3.0.0"
  count  = var.enable_custom_option_group == true ? 1 : 0

  name      = "db-management"
  stage     = var.environment
  namespace = var.namespace

  acl                = "private"
  enabled            = true
  user_enabled       = false
  versioning_enabled = true
  bucket_key_enabled = true
  kms_master_key_arn = "arn:${data.aws_partition.this.partition}:kms:${var.region}:${var.account_id}:alias/aws/s3"
  sse_algorithm      = "aws:kms"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObjectAttributes",
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ],
        Resource = [
          module.db_management[0].bucket_arn,
          "${module.db_management[0].bucket_arn}/*"
        ]
        Principal = {
          AWS = "arn:${data.aws_partition.this.partition}:iam::${var.account_id}:root"
        },
      }
    ]
  })

  privileged_principal_actions = [
    "s3:GetObject",
    "s3:ListBucket",
    "s3:GetBucketLocation"
  ]

  tags = var.tags
}

################################################################################
## option group
################################################################################
resource "aws_iam_role" "option_group" {
  count = var.enable_custom_option_group == true ? 1 : 0

  name_prefix = "${var.namespace}-${var.environment}-db-"

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
  count = var.enable_custom_option_group == true ? 1 : 0

  name_prefix = "${var.namespace}-${var.environment}-db-"

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
          Resource = "arn:${data.aws_partition.this.partition}:s3:::${var.namespace}-${var.environment}-db-management"
        },
        {
          Effect = "Allow",
          Action = [
            "s3:GetObjectAttributes",
            "s3:GetObject",
            "s3:PutObject",
            "s3:ListMultipartUploadParts",
            "s3:AbortMultipartUpload"
          ],
          Resource = "arn:${data.aws_partition.this.partition}:s3:::${var.namespace}-${var.environment}-db-management/*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "option_group" {
  count = var.enable_custom_option_group == true ? 1 : 0

  role       = aws_iam_role.option_group[0].name
  policy_arn = aws_iam_policy.option_group[0].arn
}

resource "aws_db_option_group" "this" {
  count = var.enable_custom_option_group == true ? 1 : 0

  name_prefix              = "${var.namespace}-${var.environment}-option-group-"
  option_group_description = "Custom Option Group"
  engine_name              = var.rds_instance_engine
  major_engine_version     = var.rds_instance_major_engine_version

  dynamic "option" {
    for_each = var.enable_custom_option_group == true ? [1] : [0]

    content {
      option_name = contains(["sqlserver"], var.rds_instance_engine) == true ? "SQLSERVER_BACKUP_RESTORE" : "S3_INTEGRATION"

      option_settings {
        name  = "IAM_ROLE_ARN"
        value = try(aws_iam_role.option_group[0].arn, "")
      }
    }
  }

  tags = var.tags
}

################################################################################
## rds
################################################################################
module "rds_instance" {
  count  = var.rds_instance_enabled == true ? 1 : 0
  source = "git::https://github.com/cloudposse/terraform-aws-rds?ref=0.40.0"

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
  option_group_name                   = var.enable_custom_option_group == true ? aws_db_option_group.this[0].name : var.rds_instance_option_group_name
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

  tags = var.tags
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
