################################################################################
## shared
################################################################################
variable "vpc_id" {
  type        = string
  description = "vpc_id for the VPC to run the cluster."
}

variable "enhanced_monitoring_name" {
  type        = string
  description = "Name to assign the enhanced monitoring resources."
}

variable "enhanced_monitoring_arn" {
  type        = string
  description = "ARN to the enhanced monitoring policy"
  default     = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

variable "deletion_protection" {
  description = "Protect the instance from being deleted"
  type        = bool
  default     = false
}


variable "timeouts" {
  type = object({
    create = string
    update = string
    delete = string
  })
  description = "A list of DB timeouts to apply to the running code while creating, updating, or deleting the DB instance."
  default = {
    create = "40m"
    update = "80m"
    delete = "60m"
  }
}

################################################################################
## aurora
################################################################################
variable "aurora_cluster_enabled" {
  type        = bool
  description = "Enable creation of an Aurora Cluster"
  default     = false
}

variable "aurora_cluster_name" {
  type        = string
  description = "Database name (default is not to create a database)"
  default     = ""
}

variable "aurora_db_admin_username" {
  type        = string
  description = "Name of the default DB admin user role"
  default     = ""
}

variable "aurora_db_admin_password" {
  type        = string
  description = "Password of the DB admin"
  sensitive   = true
  default     = ""
}

variable "aurora_db_name" {
  type        = string
  default     = "auroradb"
  description = "Database name."
}

variable "aurora_cluster_family" {
  type        = string
  default     = "aurora-postgresql14"
  description = "The family of the DB cluster parameter group"
}

variable "aurora_engine" {
  type        = string
  default     = "aurora-postgresql"
  description = "The name of the database engine to be used for this DB cluster. Valid values: `aurora`, `aurora-mysql`, `aurora-postgresql`"
}

variable "aurora_engine_mode" {
  type        = string
  default     = "provisioned"
  description = "The database engine mode. Valid values: `parallelquery`, `provisioned`, `serverless`"
}

variable "aurora_engine_version" {
  description = "The version of the database engine tocl use. See `aws rds describe-db-engine-versions` "
  type        = string
  default     = "14.5" // "aurora-postgresql14.5"
}

variable "aurora_allow_major_version_upgrade" {
  type        = bool
  default     = false
  description = "Enable to allow major engine version upgrades when changing engine versions. Defaults to false."
}

variable "aurora_auto_minor_version_upgrade" {
  type        = bool
  default     = true
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
}

variable "aurora_cluster_size" {
  type        = number
  default     = 0
  description = "Number of DB instances to create in the cluster"
}

variable "aurora_instance_type" {
  type        = string
  default     = "db.serverless"
  description = "Instance type to use"
}

variable "aurora_subnets" {
  type        = list(string)
  description = "Subnets for the cluster to run in."
  default     = []
}

variable "aurora_security_groups" {
  type        = list(string)
  default     = []
  description = "List of security group IDs to be allowed to connect to the DB instance"
}

variable "aurora_allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks allowed to access the cluster"
}

variable "aurora_scaling_configuration" {
  description = "List of nested attributes with scaling properties. Only valid when engine_mode is set to serverless"
  type = list(object({
    auto_pause               = bool
    max_capacity             = number
    min_capacity             = number
    seconds_until_auto_pause = number
    timeout_action           = string
  }))
  default = []
}

variable "aurora_serverlessv2_scaling_configuration" {
  description = "serverlessv2 scaling properties"
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default = null
}

################################################################################
## option group
################################################################################
variable "enable_custom_option_group" {
  description = "Enable the custom Option Group for restoring backups via S3"
  type        = bool
  default     = false
}

variable "region" {
  description = "Region which the resource is deployed to"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "Account ID where the resources will be deployed to. This is required if `enable_custom_option_group` is set to `true`."
  type        = string
  default     = ""
}

variable "s3_kms_alias_override" {
  description = "Override the KMS key alias for the S3 bucket. Default is set to AWS Managed KMS alias."
  type        = string
  default     = ""
}

################################################################################
## rds
################################################################################
variable "rds_random_admin_password_length" {
  description = "Length of the generated random password."
  type        = number
  default     = 64
}

variable "rds_instance_enabled" {
  type        = bool
  description = "Enable creation of an RDS instance"
  default     = false
}

variable "rds_instance_name" {
  type        = string
  description = "RDS Instance name"
  default     = ""
}

variable "rds_instance_dns_zone_id" {
  type        = string
  description = "The ID of the DNS Zone in Route53 where a new DNS record will be created for the DB host name"
  default     = ""
}

variable "deletion_window_in_days" {
  type    = number
  default = 10
}

variable "enable_key_rotation" {
  type    = bool
  default = true
}

variable "rds_instance_host_name" {
  type        = string
  description = "The DB host name created in Route53"
  default     = "db"
}

variable "rds_instance_database_name" {
  type        = string
  description = "The name of the database to create when the DB instance is created"
  default     = null
}

variable "rds_instance_database_user" {
  type        = string
  description = "The name of the database to create when the DB instance is created"
  default     = "admin"
}

variable "rds_instance_database_password" {
  type        = string
  description = "Password for the primary DB user. Required unless a snapshot_identifier or replicate_source_db is provided."
  sensitive   = true
  default     = ""
}

variable "rds_instance_database_port" {
  type        = number
  description = "Database port (_e.g._ 3306 for MySQL). Used in the DB Security Group to allow access to the DB instance from the provided security_group_ids"
  default     = 5432
}

variable "rds_instance_engine" {
  type        = string
  description = "Database engine type. Required unless a snapshot_identifier or replicate_source_db is provided. For supported values, see the Engine parameter in API action CreateDBInstance."
  default     = "postgres"
}

variable "rds_instance_engine_version" {
  type        = string
  description = "Database engine version, depends on engine type. Required unless a snapshot_identifier or replicate_source_db is provided."
  default     = "14.3"
}

variable "rds_instance_major_engine_version" {
  type        = string
  description = "major_engine_version	Database MAJOR engine version, depends on engine type"
  default     = "14"
}

variable "rds_instance_db_parameter_group" {
  type        = string
  description = "The DB parameter group family name. The value depends on DB engine used. See DBParameterGroupFamily for instructions on how to retrieve applicable value."
  default     = "postgres14"
}

variable "rds_kms_key_arn_override" {
  type        = string
  description = "Override the default created KMS key to encrypt storage"
  default     = ""
}

variable "rds_kms_key_id_override" {
  type        = string
  description = "Override the default created KMS key ID to encrypt storage"
  default     = ""
}

variable "rds_instance_db_parameter" {
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  description = "A list of DB parameters to apply. Note that parameters may differ from a DB family to another"
  default     = []
}

variable "rds_instance_db_options" {
  type = list(object({
    db_security_group_memberships  = list(string)
    option_name                    = string
    port                           = number
    version                        = string
    vpc_security_group_memberships = list(string)

    option_settings = list(object({
      name  = string
      value = string
    }))
  }))
  description = "A list of DB options to apply with an option group. Depends on DB engine"
  default     = []
}

variable "rds_instance_option_group_name" {
  type        = string
  description = "Name of the DB option group to associate"
  default     = ""
}

variable "rds_instance_ca_cert_identifier" {
  type        = string
  description = "The identifier of the CA certificate for the DB instance"
  default     = null
}

variable "rds_instance_publicly_accessible" {
  type        = bool
  description = "Determines if database can be publicly available (NOT recommended)"
  default     = false
}

variable "rds_instance_multi_az" {
  type        = bool
  description = "Set to true if multi AZ deployment must be supported"
  default     = false
}

variable "rds_instance_storage_type" {
  type        = string
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD)"
  default     = "gp2"
}

variable "rds_instance_instance_class" {
  type        = string
  description = "Class of RDS instance"
  default     = "db.t2.medium"
}

variable "rds_instance_allocated_storage" {
  type        = number
  description = "The allocated storage in GBs. Required unless a snapshot_identifier or replicate_source_db is provided."
  default     = 20
}

variable "rds_instance_storage_encrypted" {
  type        = bool
  description = "Specifies whether the DB instance is encrypted. The default is false if not specified"
  default     = true
}

variable "rds_instance_snapshot_identifier" {
  type        = string
  description = "Snapshot identifier e.g: rds:production-2019-06-26-06-05. If specified, the module create cluster from the snapshot"
  default     = null
}

variable "rds_instance_auto_minor_version_upgrade" {
  type        = bool
  description = "Allow automated minor version upgrade (e.g. from Postgres 9.5.3 to Postgres 9.5.4)"
  default     = true
}

variable "rds_instance_allow_major_version_upgrade" {
  type        = bool
  description = "Allow major version upgrade"
  default     = false
}

variable "rds_instance_apply_immediately" {
  type        = bool
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window"
  default     = true
}

variable "rds_instance_maintenance_window" {
  type        = string
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi' UTC"
  default     = "Mon:03:00-Mon:04:00"
}

variable "rds_instance_skip_final_snapshot" {
  type        = bool
  description = "If true (default), no snapshot will be made before deleting DB"
  default     = true
}

variable "rds_instance_copy_tags_to_snapshot" {
  type        = bool
  description = "Copy tags from DB to a snapshot"
  default     = true
}

variable "rds_instance_backup_retention_period" {
  type        = number
  description = "Backup retention period in days. Must be > 0 to enable backups"
  default     = 0
}

variable "rds_instance_backup_window" {
  type        = string
  description = "When AWS can perform DB snapshots, can't overlap with maintenance window"
  default     = "22:00-03:00"
}

variable "rds_instance_security_group_ids" {
  type        = list(string)
  description = "The IDs of the security groups from which to allow ingress traffic to the DB instance"
  default     = []
}

variable "rds_instance_allowed_cidr_blocks" {
  type        = list(string)
  description = "The whitelisted CIDRs which to allow ingress traffic to the DB instance"
  default     = []
}

variable "rds_instance_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the DB. DB instance will be created in the VPC associated with the DB subnet group provisioned using the subnet IDs. Specify one of subnet_ids, db_subnet_group_name or availability_zone"
  default     = []
}

variable "rds_instance_license_model" {
  type        = string
  description = "License model for this DB. Optional, but required for some DB Engines. Valid values: license-included | bring-your-own-license | general-public-license"
  default     = ""
}

variable "performance_insights_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable Performance Insights"
}

variable "performance_insights_retention_period" {
  description = "Amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years)"
  type        = number
  default     = null
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "Additional security group IDs to apply to the cluster, in addition to the provisioned default security group with ingress traffic from existing CIDR blocks and existing security groups"

  default = []
}

variable "kms_key_arn" {
  type        = string
  description = "The ARN for the KMS encryption key. When specifying `kms_key_arn`, `storage_encrypted` needs to be set to `true`"
  default     = ""
}

variable "iam_database_authentication_enabled" {
  type        = bool
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled"
  default     = false
}

variable "aurora_storage_type" {
  type        = string
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD) or aurora-iopt1"
  default     = null
}

variable "aurora_iops" {
  type        = number
  description = "The amount of provisioned IOPS. Setting this implies a storage_type of 'io1'. This setting is required to create a Multi-AZ DB cluster. Check TF docs for values based on db engine"
  default     = null
}
