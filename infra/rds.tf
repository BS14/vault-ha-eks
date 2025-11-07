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

# Generate a random password for the database
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store the generated password in AWS SSM Parameter Store as a secret
resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.project}/rds/master_password"
  type  = "SecureString"
  value = random_password.db_password.result

  tags = merge(local.common_tags, {
    "Name" = "${var.project}-rds-password"
  })
}

# RDS instance
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.13.1"

  identifier = "${var.project}-rds-db"

  engine                 = "postgres"
  engine_version         = "17.6"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp3"
  publicly_accessible    = false
  db_name                = var.db_name
  username               = var.db_username
  password               = random_password.db_password.result
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  multi_az               = false # Set to true for production
  skip_final_snapshot    = true  # Set to false for production
  tags = merge(local.common_tags, {
    "Name" = "${var.project}-rds-db"
  })
  depends_on = [
    aws_ssm_parameter.db_password
  ]
}
