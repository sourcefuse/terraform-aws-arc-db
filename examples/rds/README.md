<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0, < 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.74.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rds"></a> [rds](#module\_rds) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `"poc"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `"arc"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Instance or Cluster ARN |
| <a name="output_database"></a> [database](#output\_database) | Database name |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Instance or Cluster Endpoint |
| <a name="output_id"></a> [id](#output\_id) | Instance or Cluster ID |
| <a name="output_identifier"></a> [identifier](#output\_identifier) | Instance or Cluster Identifier |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | Instance or Cluster KMS Key ID |
| <a name="output_monitoring_role_arn"></a> [monitoring\_role\_arn](#output\_monitoring\_role\_arn) | Instance or Cluster Monitoring Role ARN |
| <a name="output_performance_insights_kms_key_id"></a> [performance\_insights\_kms\_key\_id](#output\_performance\_insights\_kms\_key\_id) | Instance or Cluster Performance Insights KMS Key ID |
| <a name="output_port"></a> [port](#output\_port) | Database server port |
| <a name="output_username"></a> [username](#output\_username) | Username for the Database |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
