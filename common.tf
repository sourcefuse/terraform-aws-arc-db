

resource "aws_db_subnet_group" "this" {
  count = var.db_subnet_group_data.create ? 1 : 0

  name        = var.db_subnet_group_data.name
  description = var.db_subnet_group_data.description
  subnet_ids  = var.db_subnet_group_data.subnet_ids

  tags = var.tags
}

resource "aws_db_option_group" "this" {
  count = var.option_group_config.create ? 1 : 0

  name                     = var.option_group_config.name
  engine_name              = var.option_group_config.engine_name
  major_engine_version     = var.option_group_config.major_engine_version
  option_group_description = var.option_group_config.description

  dynamic "option" {
    for_each = var.option_group_config.options
    content {
      option_name = option.value.option_name
      port        = option.value.port
      version     = option.value.version

      dynamic "option_settings" {
        for_each = option.value.option_settings
        content {
          name  = option_settings.value.name
          value = option_settings.value.value
        }
      }
    }
  }

  tags = var.tags
}

resource "aws_db_parameter_group" "this" {
  count = var.parameter_group_config.create ? 1 : 0

  name        = var.parameter_group_config.name
  family      = var.parameter_group_config.family
  description = var.parameter_group_config.description

  dynamic "parameter" {
    for_each = var.parameter_group_config.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = var.tags
}

################################################################################
## KMS
################################################################################

resource "aws_kms_key" "this" {
  count = var.kms_data.create ? 1 : 0

  description             = var.kms_data.description == null ? "RDS KMS key" : var.kms_data.description
  deletion_window_in_days = var.kms_data.deletion_window_in_days
  enable_key_rotation     = var.kms_data.enable_key_rotation

  tags = merge(var.tags, {
    Name = var.kms_data.name == null ? "${local.prefix}-${var.name}-kms-key" : var.kms_data.name
  })
}

resource "aws_kms_alias" "this" {
  count = var.kms_data.create ? 1 : 0

  name          = var.kms_data.name == null ? "alias/${local.prefix}-${var.name}-kms-key" : "alias/${var.kms_data.name}"
  target_key_id = aws_kms_key.this[0].id
}

################################################################################
## IAM - create IAM role for monitoring
################################################################################
resource "aws_iam_role" "enhanced_monitoring" {
  count = var.monitoring_interval > 0 && var.monitoring_role_arn == null ? 1 : 0
  name  = "${local.prefix}-${var.name}-enhanced-monitoring-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      },
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "logs" {
  count = var.monitoring_interval > 0 && var.monitoring_role_arn == null ? 1 : 0

  name        = "${local.prefix}-${var.name}-policy"
  description = "Policy for RDS Enhanced Monitoring"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
        ],
        Resource = [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/rds/instance/*:log-stream:*",
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/rds/cluster/*:log-stream:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  count = var.monitoring_interval > 0 && var.monitoring_role_arn == null ? 1 : 0

  role       = aws_iam_role.enhanced_monitoring[0].name
  policy_arn = aws_iam_policy.logs[0].arn
}

data "aws_iam_policy" "enhanced_monitoring" {
  count = var.monitoring_interval > 0 && var.monitoring_role_arn == null ? 1 : 0
  arn   = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  count = var.monitoring_interval > 0 && var.monitoring_role_arn == null ? 1 : 0

  role       = aws_iam_role.enhanced_monitoring[0].name
  policy_arn = data.aws_iam_policy.enhanced_monitoring[0].arn
}
