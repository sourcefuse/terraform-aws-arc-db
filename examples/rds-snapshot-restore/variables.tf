variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
  default     = "dev"
}

variable "namespace" {
  type        = string
  description = "Namespace for the resources"
  default     = "arc"
}

variable "snapshot_identifier" {
  type        = string
  description = "The snapshot ID to restore from (e.g., rds:production-2024-01-15-06-05 or snapshot ARN)"
}

variable "engine_version" {
  type        = string
  description = "PostgreSQL engine version (optional - will use snapshot's version if not specified)"
  default     = null
}

variable "instance_class" {
  type        = string
  description = "The instance class for the RDS instance"
  default     = "db.t3.medium"
}

variable "allocated_storage" {
  type        = number
  description = "The allocated storage in GBs"
  default     = 100
}

variable "apply_immediately" {
  type        = bool
  description = "Whether to apply changes immediately or during maintenance window"
  default     = false
}