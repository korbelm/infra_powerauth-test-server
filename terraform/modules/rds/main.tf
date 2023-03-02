resource "aws_security_group" "main" {
  name   = "${var.name_prefix}-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 5432
    to_port     = 5432
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "${var.name_prefix}-subnet-group"
  subnet_ids = data.aws_subnets.default.ids.*
}

resource "aws_db_instance" "main" {
  identifier                  = "${var.name_prefix}-rds"
  engine                      = "postgres"
  engine_version              = 11
  allow_major_version_upgrade = false
  db_name                     = var.db_name
  username                    = var.username
  password                    = var.password
  instance_class              = var.instance_class
  allocated_storage           = var.storage
  apply_immediately           = true
  skip_final_snapshot         = true
  db_subnet_group_name        = aws_db_subnet_group.subnet_group.id
  vpc_security_group_ids      = [aws_security_group.main.id]
  deletion_protection         = true
}
