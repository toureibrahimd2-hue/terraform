# RDS Module - Main Configuration

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.project_name}-db-subnet-group"
    Environment = var.environment
  }
}

# RDS MySQL Instance
resource "aws_db_instance" "main" {
  identifier             = "${var.project_name}-db"
  allocated_storage      = var.allocated_storage
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  
  # Protection and Backups
  skip_final_snapshot       = var.environment == "prod" ? false : true
  final_snapshot_identifier = var.environment == "prod" ? "${var.project_name}-db-final-snapshot" : null
  deletion_protection       = var.environment == "prod" ? true : false
  backup_retention_period   = var.environment == "prod" ? 7 : 1
  backup_window             = "03:00-04:00"
  maintenance_window        = "Mon:04:00-Mon:05:00"
  
  # High Availability (Multi-AZ)
  multi_az = var.environment == "prod" ? true : false
  
  # Encryption at rest
  storage_encrypted = true
  
  vpc_security_group_ids = [var.db_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  publicly_accessible    = false

  tags = {
    Name        = "${var.project_name}-rds"
    Environment = var.environment
  }
}