variable "db_admin_username" {
  type        = string
  description = "Name of the default DB admin user role"
}

variable "db_name" {
  type        = string
  default     = "auroradb"
  description = "Database name."
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "cluster_family" {
  type        = string
  default     = "aurora-postgresql10"
  description = "The family of the DB cluster parameter group"
}

variable "engine" {
  type        = string
  default     = "aurora-postgresql"
  description = "The name of the database engine to be used for this DB cluster. Valid values: `aurora`, `aurora-mysql`, `aurora-postgresql`"
}

variable "engine_mode" {
  type        = string
  default     = "serverless"
  description = "The database engine mode. Valid values: `parallelquery`, `provisioned`, `serverless`"
}

variable "engine_version" {
  type        = string
  default     = "aurora-postgresql13.3"
  description = "The version of the database engine to use. See `aws rds describe-db-engine-versions` "
}

variable "allow_major_version_upgrade" {
  type        = bool
  default     = false
  description = "Enable to allow major engine version upgrades when changing engine versions. Defaults to false."
}

variable "auto_minor_version_upgrade" {
  type        = bool
  default     = true
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
}

variable "cluster_size" {
  type        = number
  default     = 0
  description = "Number of DB instances to create in the cluster"
}

variable "instance_type" {
  type        = string
  default     = "db.t3.medium"
  description = "Instance type to use"
}

variable "vpc_id" {
  type        = string
  description = "vpc_id for the VPC to run the cluster."
}

variable "subnets" {
  type        = list(string)
  description = "Subnets for the cluster to run in."
}

variable "security_groups" {
  type        = list(string)
  default     = []
  description = "List of security groups to be allowed to connect to the DB instance"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks allowed to access the cluster"
}
