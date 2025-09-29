################################################################################
## Data sources for VPC and Subnets
################################################################################

# Get the default VPC or specify your VPC
data "aws_vpc" "this" {
  default = true
  # Or use a specific VPC:
  # tags = {
  #   Name = "your-vpc-name"
  # }
}

# Get private subnets for DB subnet group
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  
  # If you have tagged private subnets:
  # tags = {
  #   Type = "private"
  # }
}