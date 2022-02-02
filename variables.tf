variable "db_admin_username" {
  type        = string
  default     = "db_admin"
  description = "Name of the default DB admin user role"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "profile" {
  type        = string
  default     = "default"
  description = "Name of the AWS profile to use"
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

variable "custom_vpc_id" {
  type        = string
  default     = ""
  description = "by default this module picks the vpc with the name tag refarch-${var.environment}-vpc, if you need to specify a custom vpc, set the vpc id of that vpc in this variable"
}

variable "custom_subnets" {
  type        = list(string)
  default     = []
  description = "pass a custom list of subnet ids for the database instance to be launched into"
}

variable "custom_security_groups" {
  type        = list(sting)
  default     = []
  description = "pass a custom list of security group ids to be attaached to the rds instance"
}
