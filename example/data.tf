################################################
## imports
################################################
## vpc
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["*dev-vpc*"]
  }
}

## network
data "aws_subnets" "private" {
  filter {
    name = "tag:Name"
    values = [
      "*-${var.environment}-private-subnet-private-${var.region}a",
      "*-${var.environment}-private-subnet-private-${var.region}b"
    ]
  }
}

## security
data "aws_security_groups" "db_sg" {
  filter {
    name   = "group-name"
    values = ["example-${var.environment}-db-sg"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}
