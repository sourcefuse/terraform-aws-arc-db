provider "aws" {
  region  = var.region
  profile = var.profile
}

module "ref_arch_db" {
  source            = "../."
  region            = var.region
  security_groups   = data.aws_security_groups.db_sg.ids
  subnets           = data.aws_subnet_ids.private.ids
  vpc_id            = data.aws_vpc.vpc.id
  db_admin_username = var.db_admin_username
  environment       = var.environment
  namespace         = var.namespace
}
