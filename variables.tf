variable "environment" {
  type        = string
  description = "ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'"
}

variable "namespace" {
  type        = string
  description = "Namespace for the resources."
}


variable "name" {
  description = "The identifier for the RDS instance or cluster."
  type        = string
}

variable "vpc_id" {
  type        = string
  description = "VPC Id for creating security group"
}

variable "serverlessv2_scaling_config" {
  type = object({
    max_capacity = number
    min_capacity = number
  })
  default = {
    max_capacity = 1.0
    min_capacity = 0.5
  }
  description = <<EOT
Configuration for Serverless V2 scaling:
- max_capacity: (Required) The maximum ACU capacity for scaling (e.g., 256.0).
- min_capacity: (Required) The minimum ACU capacity for scaling (e.g., 0.5).
EOT
}

variable "engine_type" {
  type        = string
  description = "(optional) Engine type, valid values are 'rds' or 'cluster'"

  validation {
    condition     = contains(["rds", "cluster"], var.engine_type)
    error_message = "The engine_type variable must be either 'rds' or 'cluster'."
  }
}

variable "engine" {
  description = "The database engine to use for the RDS cluster (e.g., aurora, aurora-mysql, aurora-postgresql)."
  type        = string
}

# Engine version
variable "engine_version" {
  description = "The version of the database engine to use."
  type        = string
}

variable "engine_mode" {
  type        = string
  description = <<-EOT
  (optional) Database engine mode. Valid values: global (only valid for Aurora MySQL 1.21 and earlier), parallelquery, provisioned, serverless. Defaults to: provisioned
  Note :- For Serverless V2 , engine_mode should be "provisioned" but for simplecity  "serverless" is expected
  Refer : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster#rds-serverless-v2-cluster
  EOT
  default     = "provisioned"
}

variable "engine_lifecycle_support" {
  type        = string
  description = "(optional) The life cycle type for this DB instance. This setting is valid for cluster types Aurora DB clusters and Multi-AZ DB clusters. Valid values are open-source-rds-extended-support, open-source-rds-extended-support-disabled. Default value is open-source-rds-extended-support"
  default     = "open-source-rds-extended-support"
}

variable "skip_final_snapshot" {
  type        = string
  description = "(optional) Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from final_snapshot_identifier. Default is false."
  default     = true
}

variable "final_snapshot_identifier" {
  type        = string
  description = "(optional) Name of your final DB snapshot when this DB cluster is deleted. If omitted, no final snapshot will be made."
  default     = null
}

variable "storage_type" {
  type        = string
  description = "(optional) Required for Multi-AZ DB cluster) (Forces new for Multi-AZ DB clusters) Specifies the storage type to be associated with the DB cluster. For Aurora DB clusters, storage_type modifications can be done in-place. For Multi-AZ DB Clusters, the iops argument must also be set. Valid values are: \"\", aurora-iopt1 (Aurora DB Clusters); io1, io2 (Multi-AZ DB Clusters). Default: \"\" (Aurora DB Clusters); io1 (Multi-AZ DB Clusters)."
  default     = ""
}

variable "port" {
  type        = number
  description = "Port on which the DB accepts connections"
}

# Master username
variable "username" {
  description = "The username for the database."
  type        = string
}

# Master password
variable "password" {
  description = "The password for the database."
  type        = string
  sensitive   = true
  default     = null
}

variable "manage_user_password" {
  type        = bool
  description = <<-EOT
    (optional) Set to true to allow RDS to manage the master user password in Secrets Manager. Cannot be set if master_password is provided."
    null - is equal to 'false', don't set it to false , known bug :  https://github.com/hashicorp/terraform-provider-aws/issues/31179
  EOT
  default     = null
}

# Database name
variable "database_name" {
  description = "The name of the database to create when the cluster is created."
  type        = string
  default     = null
}

# DB subnet group name
variable "db_subnet_group_data" {
  type = object({
    name        = string
    create      = optional(bool, false)
    description = optional(string, null)
    subnet_ids  = optional(list(string), [])
  })
  description = "(optional) DB Subnet Group details"
}

# Backup retention period
variable "backup_retention_period" {
  description = "The number of days to retain backups for the DB cluster."
  type        = number
  default     = 7
}

# Preferred backup window
variable "preferred_backup_window" {
  description = "The daily time range during which backups are taken."
  type        = string
  default     = "07:00-09:00"
}

# Preferred maintenance window
variable "preferred_maintenance_window" {
  description = "The weekly time range during which maintenance can occur."
  type        = string
  default     = "sun:06:00-sun:07:00"
}

# Enable storage encryption
variable "storage_encrypted" {
  description = "Whether to enable storage encryption."
  type        = bool
  default     = true
}

# Enable IAM database authentication
variable "iam_database_authentication_enabled" {
  description = "Enable IAM database authentication for the RDS cluster."
  type        = bool
  default     = false
}

# Enable deletion protection
variable "deletion_protection" {
  description = "Whether to enable deletion protection for the DB cluster."
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  type        = bool
  description = "(optional) Valid only for Non-Aurora Multi-AZ DB Clusters. Enables Performance Insights for the RDS Cluster"
  default     = false
}

variable "network_type" {
  type        = string
  description = "(optional) Network type of the cluster. Valid values: IPV4, DUAL."
  default     = "IPV4"
}

# Copy tags to snapshots
variable "copy_tags_to_snapshot" {
  description = "Whether to copy all tags to snapshots."
  type        = bool
  default     = true
}

variable "db_cluster_parameter_group_name" {
  type        = string
  description = "(optional) A cluster parameter group to associate with the cluster."
  default     = null
}

variable "db_instance_parameter_group_name" {
  type        = string
  description = "(optional) Instance parameter group to associate with all instances of the DB cluster. The db_instance_parameter_group_name parameter is only valid in combination with the allow_major_version_upgrade parameter."
  default     = null
}

variable "ca_certificate_identifier" {
  type        = string
  description = "(optional) The CA certificate identifier to use for the DB cluster's server certificate."
  default     = null
}

variable "delete_automated_backups" {
  type        = string
  description = "(optional) Specifies whether to remove automated backups immediately after the DB cluster is deleted. Default is true."
  default     = true
}

variable "rds_cluster_instances" {
  type = list(object({
    name                    = optional(string, null)
    instance_class          = string
    availability_zone       = optional(string, null)
    publicly_accessible     = optional(bool, false)
    db_parameter_group_name = optional(string, null)
    promotion_tier          = optional(number, 0)
    copy_tags_to_snapshot   = optional(bool, true)
  }))
  description = <<-EOT
  "(optional) A list of objects defining configurations for RDS Cluster instances. Each object represents a single RDS instance configuration within the cluster, including options for instance class, monitoring, performance insights, maintenance windows, and other instance-specific settings."
      name: Optional. Name of the instance (default: null).
      instance_class: The instance class for the RDS instance (e.g., db.r5.large).
      availability_zone: Optional. Specifies the availability zone for the instance (default: null).
      publicly_accessible: Optional. Whether the instance is publicly accessible (default: false).
      db_parameter_group_name: Optional. The name of the DB parameter group to associate with the instance (default: null).
      apply_immediately: Optional. Apply modifications immediately or during the next maintenance window (default: false).
      preferred_maintenance_window: Optional. The weekly maintenance window for the instance (default: null).
      auto_minor_version_upgrade: Optional. Automatically apply minor version upgrades (default: true).
      ca_cert_identifier: Optional. Identifier for the CA certificate for the instance (default: null).
      monitoring_interval: Optional. Monitoring interval for Enhanced Monitoring (default: 0 - disabled).
      monitoring_role_arn: Optional. The ARN of the IAM role used for Enhanced Monitoring (default: null).
      performance_insights_enabled: Optional. Whether to enable Performance Insights (default: false).
      performance_insights_kms_key_id: Optional. KMS key ID for Performance Insights encryption (default: null).
      performance_insights_retention_period: Optional. Retention period for Performance Insights data (default: 7 days).
      promotion_tier: Optional. Promotion tier for the instance within the cluster (default: 0).
      copy_tags_to_snapshot: Optional. Copy tags to snapshots (default: true).
    EOT
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the DB Cluster."
  type        = map(string)
  default     = {}
}

variable "security_group_data" {
  type = object({
    security_group_ids_to_attach = optional(list(string), [])
    create                       = optional(bool, true)
    description                  = optional(string, null)
    ingress_rules = optional(list(object({
      description              = optional(string, null)
      cidr_block               = optional(string, null)
      source_security_group_id = optional(string, null)
      from_port                = number
      ip_protocol              = string
      to_port                  = string
    })), [])
    egress_rules = optional(list(object({
      description                   = optional(string, null)
      cidr_block                    = optional(string, null)
      destination_security_group_id = optional(string, null)
      from_port                     = number
      ip_protocol                   = string
      to_port                       = string
    })), [])
  })
  description = "(optional) Security Group data"
  default = {
    create = false
  }
}

variable "proxy_config" {
  type = object({
    create                   = optional(bool, false)
    name                     = optional(string, null)
    engine_family            = string
    vpc_subnet_ids           = list(string)
    require_tls              = optional(bool, false)
    debug_logging            = optional(bool, false)
    idle_client_timeout_secs = optional(number, 30 * 60) // in seconds The minimum is 1 minute and the maximum is 8 hours.
    role_arn                 = optional(string, null)    // null value will create new role
    auth = object({
      auth_scheme               = string
      description               = optional(string, null)
      iam_auth                  = optional(string, "DISABLED")
      client_password_auth_type = string
    })
    additional_auth_list = optional(list(object({
      auth_scheme               = string
      secret_arn                = optional(string, null)
      description               = optional(string, null)
      iam_auth                  = optional(string, "DISABLED")
      client_password_auth_type = string
    })), [])
    connection_pool_config = object({
      connection_borrow_timeout    = optional(number, 5)
      init_query                   = optional(string, null)
      max_connections_percent      = optional(number, 100)
      max_idle_connections_percent = optional(number, 50)
      session_pinning_filters      = optional(list(string), [])
    })
    security_group_data = optional(object({
      security_group_ids_to_attach = optional(list(string), [])
      create                       = optional(bool, true)
      description                  = optional(string, null)
      ingress_rules = optional(list(object({
        description              = optional(string, null)
        cidr_block               = optional(string, null)
        source_security_group_id = optional(string, null)
        from_port                = number
        ip_protocol              = string
        to_port                  = string
        self                     = optional(bool, false)
      })), [])
      egress_rules = optional(list(object({
        description                   = optional(string, null)
        cidr_block                    = optional(string, null)
        destination_security_group_id = optional(string, null)
        from_port                     = number
        ip_protocol                   = string
        to_port                       = string
      })), [])
    }))
  })
  description = <<EOD
Configuration object for setting up an AWS RDS Proxy. It includes options for creating the proxy, connection pooling, authentication, and other proxy-specific settings.

- **create** (optional): A boolean that determines whether to create the RDS Proxy resource. Defaults to false.
- **name** (optional): The name of the RDS Proxy. If not specified, Terraform will create a default name.
- **engine_family**: The database engine family for the proxy (e.g., "MYSQL", "POSTGRESQL").
- **vpc_subnet_ids**: List of VPC subnet IDs in which the proxy will be deployed.
- **security_group_data**: List of security groups to associate with the RDS Proxy.
- **require_tls** (optional): Boolean flag to enforce the use of TLS for client connections to the proxy. Defaults to false.
- **debug_logging** (optional): Boolean flag to enable debug logging for the proxy. Defaults to false.
- **idle_client_timeout_secs** (optional): Number of seconds before the proxy closes idle client connections. The minimum is 60 seconds (1 minute), and the maximum is 28,800 seconds (8 hours). Defaults to 1,800 seconds (30 minutes).
- **role_arn** (optional): The ARN of the IAM role used by the proxy for accessing database credentials in AWS Secrets Manager. If null, Terraform will create a new IAM role.

Authentication settings:
- **auth.auth_scheme**: The authentication scheme to use (e.g., "SECRETS").
- **auth.description** (optional): A description of the authentication method. Defaults to null.
- **auth.iam_auth** (optional): Specifies whether to use IAM authentication for the proxy. Defaults to "DISABLED".
- **auth.secret_arn**: The ARN of the AWS Secrets Manager secret that contains the database credentials.
- **auth.client_password_auth_type**: Specifies the password authentication type for the database.

Connection pool configuration:
- **connection_pool_config.connection_borrow_timeout** (optional): The amount of time (in seconds) a client connection can be held open before being returned to the pool. Defaults to 5 seconds.
- **connection_pool_config.init_query** (optional): An optional initialization query executed when a connection is first established. Defaults to null.
- **connection_pool_config.max_connections_percent** (optional): The maximum percentage of available database connections that the proxy can use. Defaults to 100%.
- **connection_pool_config.max_idle_connections_percent** (optional): The maximum percentage of idle database connections that the proxy can keep open. Defaults to 50%.
- **connection_pool_config.session_pinning_filters** (optional): List of filters for controlling session pinning behavior. Defaults to an empty list.

EOD
  default = {
    create                 = false
    engine_family          = "POSTGRESQL"
    vpc_subnet_ids         = []
    auth                   = null
    connection_pool_config = null
    security_group_data = {
      create = false
    }
  }
}


variable "kms_data" {
  type = object({
    create                          = optional(bool, true)
    kms_key_id                      = optional(string, null)
    performance_insights_kms_key_id = optional(string, null)
    name                            = optional(string, null)
    description                     = optional(string, null)
    policy                          = optional(string, null)
    deletion_window_in_days         = optional(number, 7)
    enable_key_rotation             = optional(bool, true)
  })
  description = <<EOT
Configuration for KMS key settings for RDS encryption and performance insights:
- create: (Optional) If true, a new KMS key is created.
- kms_key_id: (Optional) The ID of an existing KMS key for RDS encryption. If null it used AWS managed keys
- performance_insights_kms_key_id: (Optional) Key ID for Performance Insights. If null it used AWS managed keys
- description: (Optional) description for the KMS key.
- policy: (Optional) Specific policy for the KMS key.
- deletion_window_in_days: (Optional) Number of days before deletion, default is 7.
- enable_key_rotation: (Optional) Enables key rotation for security; defaults to true.
EOT
  default = {
    create = false
  }
}


variable "license_model" {
  description = "The license model for the DB instance (e.g., license-included, bring-your-own-license, general-public-license)."
  type        = string
}

variable "apply_immediately" {
  description = "Whether to apply changes immediately or during the next maintenance window."
  type        = bool
  default     = false
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected. Valid values are 0, 1, 5, 10, 15, 30, 60."
  type        = number
  default     = 0
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch Logs. Valid values: audit, error, general, slowquery."
  type        = list(string)
  default     = []
}

variable "iops" {
  description = "The amount of provisioned IOPS. Required if using io1 storage type."
  type        = number
  default     = 0
}

variable "enable_multi_az" {
  description = "Whether to enable Multi-AZ deployment for the RDS instance."
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Whether the RDS instance should be publicly accessible."
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Whether minor engine upgrades are applied automatically during the maintenance window."
  type        = bool
  default     = true
}

variable "allow_major_version_upgrade" {
  description = "Whether major version upgrades are allowed during maintenance windows."
  type        = bool
  default     = false
}

variable "ca_cert_identifier" {
  description = "The identifier of the CA certificate for the DB instance. If not specified, the RDS default CA is used."
  type        = string
  default     = null
}

variable "db_server_class" {
  type        = string
  description = "Instance class for RDS instance"
  default     = "db.t3.medium"
}

variable "allocated_storage" {
  type        = string
  description = "(optional) Storage for RDS instance"
  default     = 20
}

variable "option_group_config" {
  type = object({
    create               = optional(bool, false)
    name                 = optional(string, null)
    engine_name          = optional(string)
    major_engine_version = optional(string)
    description          = optional(string, "Managed by Terraform")
    options = map(object({
      option_name = string
      port        = number
      version     = string
      option_settings = map(object({
        name  = string
        value = string
      }))
    }))
  })
  description = "Configuration for RDS option group, with attributes to create or specify a group name, engine details, and database options including settings, ports, and versions."
  default = {
    name    = null
    options = {}
  }
}

variable "parameter_group_config" {
  type = object({
    create      = optional(bool, false)
    name        = optional(string, null)
    family      = optional(string)
    description = optional(string, "Managed by Terraform")
    parameters = map(object({
      name         = string
      value        = string
      apply_method = optional(string, "immediate") # Options: "immediate" or "pending-reboot"
    }))
  })
  description = "Configuration for RDS parameter group, with options to create or specify a group name, family, and a map of database parameters including settings and apply methods."
  default = {
    name       = null
    parameters = {}
  }
}

variable "performance_insights_retention_period" {
  description = "The retention period (in days) for Performance Insights data. Valid values are 7, 731, or any value between 8 and 730."
  type        = number
  default     = 7
}

variable "monitoring_role_arn" {
  description = "The ARN for the IAM role that allows RDS to send Enhanced Monitoring metrics to CloudWatch Logs."
  type        = string
  default     = null
}
