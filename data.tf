data "aws_kms_alias" "rds" {
  name = "alias/aws/rds"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
