data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.0"
  name    = "${var.project}-vpc"
  cidr    = var.cidr
  azs     = slice(data.aws_availability_zones.available.names, 0, 3)


  # Subnetting: /24 subnets within /16 VPC (cleaner separation)
  public_subnets  = [for i in range(3) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_subnets = [for i in range(3) : cidrsubnet(local.vpc_cidr, 8, i + 10)]
  database_subnets = [for i in range(3): cidrsubnet(local.vpc_cidr, 8, i + 20)]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
  
  database_subnet_tags = {
    "Tier" = "database"
  }
  tags = local.common_tags
}

# RDS Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project}-rds-subnet-group"
  subnet_ids = module.vpc.database_subnets

  tags = merge(local.common_tags, {
    "Name" = "${var.project}-rds-subnet-group"
  })
}
