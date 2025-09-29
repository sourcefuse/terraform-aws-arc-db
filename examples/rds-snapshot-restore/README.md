# RDS PostgreSQL Snapshot Restore Example

This example demonstrates how to restore an RDS PostgreSQL instance from an existing snapshot using the terraform-aws-arc-db module.

## Prerequisites

- An existing RDS snapshot ID or ARN
- AWS credentials configured
- VPC with subnets for the RDS instance

## Usage

1. Set your snapshot identifier:

```bash
export TF_VAR_snapshot_identifier="rds:my-production-db-2024-01-15-06-05"
# or use an ARN:
# export TF_VAR_snapshot_identifier="arn:aws:rds:us-east-1:123456789012:snapshot:my-snapshot"
```

2. Initialize and apply:

```bash
terraform init
terraform plan
terraform apply
```

## Important Notes

- When restoring from a snapshot, the following parameters from the snapshot take precedence:
  - Database engine type
  - Master username
  - Database name
  - Character set configuration

- You can override the following after restoration:
  - Instance class
  - Storage size (can only increase)
  - Engine version (for upgrades)
  - Security groups
  - Parameter groups
  - Backup settings

- The password from the snapshot is retained. If you need to reset it:
  - Use AWS Secrets Manager rotation
  - Or modify the master password after restoration

## Example with Aurora Cluster

For Aurora clusters, use `engine_type = "cluster"`:

```hcl
module "aurora_from_snapshot" {
  source = "../../"
  
  engine_type = "cluster"
  engine      = "aurora-postgresql"
  snapshot_identifier = "arn:aws:rds:us-east-1:123456789012:cluster-snapshot:my-aurora-snapshot"
  
  # ... other configuration
}
```

## Cleanup

To avoid ongoing charges, destroy the resources when done:

```bash
terraform destroy
```

Note: If `skip_final_snapshot` is set to `false`, a final snapshot will be created before deletion.