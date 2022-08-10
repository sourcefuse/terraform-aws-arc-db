################################################################################
## shared
################################################################################
variable "region" {
  type        = string
  description = "AWS region"
}

variable "vpc_id" {
  type        = string
  description = "vpc_id for the VPC to run the cluster."
}

################################################################################
## aurora
################################################################################
variable "aurora_cluster_name" {
  type        = string
  description = "Database name (default is not to create a database)"
}

variable "aurora_db_admin_username" {
  type        = string
  description = "Name of the default DB admin user role"
}

variable "aurora_db_name" {
  type        = string
  default     = "auroradb"
  description = "Database name."
}

variable "aurora_cluster_family" {
  type        = string
  default     = "aurora-postgresql10"
  description = "The family of the DB cluster parameter group"
}

variable "aurora_engine" {
  type        = string
  default     = "aurora-postgresql"
  description = "The name of the database engine to be used for this DB cluster. Valid values: `aurora`, `aurora-mysql`, `aurora-postgresql`"
}

variable "aurora_engine_mode" {
  type        = string
  default     = "serverless"
  description = "The database engine mode. Valid values: `parallelquery`, `provisioned`, `serverless`"
}

variable "aurora_engine_version" {
  type        = string
  default     = "aurora-postgresql13.3"
  description = "The version of the database engine to use. See `aws rds describe-db-engine-versions` "
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
  default     = "db.t3.medium"
  description = "Instance type to use"
}

variable "aurora_subnets" {
  type        = list(string)
  description = "Subnets for the cluster to run in."
}

variable "aurora_security_groups" {
  type        = list(string)
  default     = []
  description = "List of security groups to be allowed to connect to the DB instance"
}

variable "aurora_allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks allowed to access the cluster"
}

################################################################################
## sql server
################################################################################
variable "rds_instance_enabled" {
  type        = bool
  description = "Enable creation of an RDS instance"
  default     = false
}

variable "rds_instance_name" {
  type        = string
  description = "RDS Instance name"
}

variable "rds_instance_dns_zone_id" {
  type        = string
  description = "The ID of the DNS Zone in Route53 where a new DNS record will be created for the DB host name"
  default     = ""
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
  description = "Database engine type. Required unless a snapshot_identifier or replicate_source_db is provided."
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
