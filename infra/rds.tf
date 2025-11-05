resource "aws_security_group" "rds_sg" {
  name        = "${var.project}-rds-sg"
  description = "Allow DB access from within the VPC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow Postgres access from inside the VPC"
    from_port   = 5432 
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    "Name" = "${var.project}-rds-sg"
  })
}

