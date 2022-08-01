provider "aws" {
  region                  = var.region
}

module "ref_arch_db" {
  source              = "../."
  region              = var.region
  allowed_cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  subnets             = data.aws_subnet_ids.private.ids
  vpc_id              = data.aws_vpc.vpc.id
  db_admin_username   = var.db_admin_username
  environment         = var.environment
  namespace           = var.namespace
}
