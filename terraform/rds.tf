resource "aws_db_instance" "app" {
  count                 = var.create_db_instance ? 1 : 0
  allocated_storage     = 20
  max_allocated_storage = 200

  engine                     = "mysql"
  engine_version             = "8.0.35"
  instance_class             = "db.t3.micro"
  auto_minor_version_upgrade = true

  db_name  = "acDatabase"
  username = "acDBUser"
  password = random_password.password.result

  skip_final_snapshot     = true
  copy_tags_to_snapshot   = true
  backup_retention_period = 14

  kms_key_id        = aws_kms_key.general.arn
  storage_encrypted = true

  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.app_database.id]

  deletion_protection = true

  tags = {
    Name = "${local.naming_prefix}-app-db"
  }
}

locals {
  aws_db_instance_app_endpoint = try(aws_db_instance.app[0].endpoint, "RDS_NOT_CREATED")
  aws_db_instance_app_db_name  = try(aws_db_instance.app[0].db_name, "RDS_NOT_CREATED")
  aws_db_instance_app_username = try(aws_db_instance.app[0].username, "RDS_NOT_CREATED")
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}


resource "aws_db_subnet_group" "db" {
  name       = "${local.naming_prefix}-db-subnet-group"
  subnet_ids = aws_subnet.private_data_subnet_cidrs[*].id
}

resource "aws_security_group" "app_database" {
  name        = "${local.naming_prefix}-app-db"
  description = "DB"
  vpc_id      = aws_vpc.phi_api.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${local.naming_prefix}-app-db"
  }
}

resource "aws_security_group" "db" {
  name   = "${local.naming_prefix}-db-sg"
  vpc_id = aws_vpc.phi_api.id
}
