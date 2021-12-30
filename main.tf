resource "aws_kms_key" "aurora_cluster_kms_key" {
  description             = "Aurora cluster KMS key"
  deletion_window_in_days = 10

  tags = merge(var.tags, tomap({
    Name = "${var.namespace}-${var.environment}-aurora-cluster-key"
  }))
}

resource "aws_kms_alias" "aurora_cluster_kms_key" {
  target_key_id = aws_kms_key.aurora_cluster_kms_key.id
  name          = "alias/${var.namespace}-${var.environment}-aurora-cluster-kms-key"
}

# create IAM role for monitoring
resource "aws_iam_role" "enhanced_monitoring" {
  name               = "${var.namespace}-${var.environment}-enhanced-monitoring-role"
  assume_role_policy = data.aws_iam_policy_document.enhanced_monitoring.json
}

# Attach Amazon's managed policy for RDS enhanced monitoring
resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  role       = aws_iam_role.enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
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

resource "random_password" "db_admin_password" {
  length           = 32
  special          = true
  override_special = "_%@"

  lifecycle {
    ignore_changes = [
      id,
      length,
      lower,
      min_lower,
      min_numeric,
      min_special,
      min_upper,
      number,
      override_special,
      result,
      special,
      upper
    ]
  }
}

module "rds_cluster_aurora_postgres" {
  source                = "git::https://github.com/cloudposse/terraform-aws-rds-cluster.git?ref=0.46.2"
  engine                = var.engine
  engine_mode           = var.engine_mode
  cluster_family        = var.cluster_family
  cluster_size          = var.cluster_size
  namespace             = var.namespace
  stage                 = var.environment
  name                  = var.name
  admin_user            = var.db_admin_username
  admin_password        = random_password.db_admin_password.result
  db_name               = var.namespace
  db_port               = 5432
  vpc_id                = data.aws_vpc.vpc.id
  security_groups       = data.aws_security_groups.db_sg.ids
  subnets               = data.aws_subnet_ids.private.ids
  storage_encrypted     = true
  instance_type         = var.instance_type
  tags                  = local.tags
  copy_tags_to_snapshot = true
  # enable monitoring every 30 seconds
  rds_monitoring_interval = 30

  # reference iam role created above
  rds_monitoring_role_arn = aws_iam_role.enhanced_monitoring.arn
  scaling_configuration = [{
    auto_pause               = true
    max_capacity             = 16
    min_capacity             = 2
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }]


}

resource "aws_ssm_parameter" "this" {
  for_each = { for x in local.ssm_params : x.name => x }

  name      = lookup(each.value, "name", null)
  value     = lookup(each.value, "value", null)
  type      = lookup(each.value, "type", null)
  overwrite = true

  tags = merge(local.tags, local.ssm_tags)
}
