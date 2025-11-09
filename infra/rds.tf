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

# RDS instance
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.13.1"

  identifier = "${var.project}-rds-db"

  engine                 = "postgres"
  engine_version         = "17.6"
  family                 = "postgres17"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp3"
  publicly_accessible    = false
  db_name                = var.db_name
  username               = var.db_username
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  multi_az               = false # Set to true for production
  skip_final_snapshot    = true  # Set to false for production
  tags = merge(local.common_tags, {
    "Name" = "${var.project}-rds-db"
  })
}
