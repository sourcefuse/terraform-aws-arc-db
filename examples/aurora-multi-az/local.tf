locals {
  security_group_data = {
    create      = true
    description = "Security Group for Aurora Cluster"

    ingress_rules = [
      {
        description = "Allow Aurora traffic"
        cidr_block  = data.aws_vpc.this.cidr_block
        from_port   = 5432
        ip_protocol = "tcp"
        to_port     = 5432
      }
    ]

    egress_rules = [
      {
        description = "Allow all outbound traffic"
        cidr_block  = "0.0.0.0/0"
        from_port   = -1
        ip_protocol = "-1"
        to_port     = -1
      }
    ]
  }
}
