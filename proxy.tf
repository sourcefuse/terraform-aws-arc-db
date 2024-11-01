resource "aws_kms_key" "secret" {
  description             = "KMS key for encrypting Secrets Manager secrets"
  deletion_window_in_days = var.kms_data.deletion_window_in_days
  enable_key_rotation     = var.kms_data.enable_key_rotation

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "Enable IAM User Permissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "Allow Secrets Manager to use the key",
        Effect = "Allow",
        Principal = {
          Service = "secretsmanager.amazonaws.com"
        },
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_secretsmanager_secret" "this" {
  count = var.manage_user_password == null && var.proxy_config.create ? 1 : 0

  name        = "${local.prefix}-${var.name}-secret"
  description = "Credentials for RDS Proxy"
  kms_key_id  = var.kms_data.create ? aws_kms_key.secret.id : null
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  count = var.manage_user_password == null && var.proxy_config.create ? 1 : 0

  secret_id = aws_secretsmanager_secret.this[0].id
  secret_string = jsonencode({
    "username" = local.username
    "password" = local.password
    "database" = local.database
    "endpoint" = local.endpoint
    "port"     = local.port
  })
}


resource "aws_db_proxy" "this" {
  count = var.proxy_config.create ? 1 : 0

  name                   = var.proxy_config.name == null ? var.name : var.proxy_config.name
  engine_family          = var.proxy_config.engine_family # Replace with your DB engine (MYSQL, POSTGRESQL, etc.)
  role_arn               = var.proxy_config.role_arn == null ? aws_iam_role.proxy[0].arn : var.proxy_config.role_arn
  vpc_subnet_ids         = var.proxy_config.vpc_subnet_ids
  vpc_security_group_ids = local.proxy_security_group_ids_to_attach
  require_tls            = var.proxy_config.require_tls
  debug_logging          = var.proxy_config.debug_logging
  idle_client_timeout    = var.proxy_config.idle_client_timeout_secs

  auth {
    auth_scheme               = var.proxy_config.auth.auth_scheme
    description               = var.proxy_config.auth.description == null ? "Auth for RDS Proxy" : var.proxy_config.auth.description
    iam_auth                  = var.proxy_config.auth.iam_auth
    secret_arn                = var.manage_user_password == true ? (var.engine_type == "rds" ? aws_db_instance.this[0].master_user_secret[0].secret_arn : aws_rds_cluster.this[0].master_user_secret[0].secret_arn) : aws_secretsmanager_secret.this[0].arn
    username                  = var.proxy_config.auth.auth_scheme == "SECRETS" ? null : (var.engine_type == "rds" ? aws_db_instance.this[0].username : aws_rds_cluster.this[0].master_username)
    client_password_auth_type = var.proxy_config.auth.client_password_auth_type
  }

  dynamic "auth" {
    for_each = var.proxy_config.additional_auth_list
    content {
      auth_scheme               = auth.value.auth_scheme
      description               = auth.value.description == null ? "Auth for RDS Proxy" : auth.value.description
      iam_auth                  = auth.value.iam_auth
      secret_arn                = auth.value.secret_arn
      client_password_auth_type = auth.value.client_password_auth_type
    }
  }

  tags = var.tags
}

resource "aws_db_proxy_default_target_group" "this" {
  count = var.proxy_config.create ? 1 : 0

  db_proxy_name = aws_db_proxy.this[0].name

  connection_pool_config {
    connection_borrow_timeout    = var.proxy_config.connection_pool_config.connection_borrow_timeout
    init_query                   = var.proxy_config.connection_pool_config.init_query
    max_connections_percent      = var.proxy_config.connection_pool_config.max_connections_percent
    max_idle_connections_percent = var.proxy_config.connection_pool_config.max_idle_connections_percent
    session_pinning_filters      = var.proxy_config.connection_pool_config.session_pinning_filters
  }
}

resource "aws_db_proxy_target" "this" {
  count = var.proxy_config.create ? 1 : 0

  db_proxy_name          = aws_db_proxy.this[0].name
  target_group_name      = aws_db_proxy_default_target_group.this[0].name
  db_cluster_identifier  = var.engine_type == "cluster" ? aws_rds_cluster.this[0].cluster_identifier : null
  db_instance_identifier = var.engine_type == "rds" ? aws_db_instance.this[0].identifier : null
  depends_on             = [aws_db_instance.this, aws_rds_cluster.this]
}


resource "aws_iam_role" "proxy" {
  count = var.proxy_config.create && var.proxy_config.role_arn == null ? 1 : 0

  name = "${local.prefix}-${var.name}-proxy"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Action" : "sts:AssumeRole",
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "rds.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "read_secrets" {
  count = var.proxy_config.create && var.proxy_config.role_arn == null ? 1 : 0

  name        = "${var.name}-read-secret-proxy"
  description = "IAM policy to grant read access to secrets in AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Resource = local.secret_arn_list
      }
    ]
  })

  depends_on = [aws_rds_cluster.this, aws_db_instance.this, aws_secretsmanager_secret.this]
}


resource "aws_iam_role_policy_attachment" "proxy" {
  count = var.proxy_config.create && var.proxy_config.role_arn == null ? 1 : 0

  role       = aws_iam_role.proxy[0].name
  policy_arn = aws_iam_policy.read_secrets[0].arn
}

module "proxy_security_group" {
  source = "./modules/security-group"

  count = var.proxy_config.security_group_data.create ? 1 : 0

  name          = "${var.name}-proxy-security-group"
  description   = var.proxy_config.security_group_data.description == null ? "Allow inbound traffic and outbound traffic" : var.proxy_config.security_group_data.description
  vpc_id        = var.vpc_id
  egress_rules  = var.proxy_config.security_group_data.egress_rules
  ingress_rules = var.proxy_config.security_group_data.ingress_rules
}
