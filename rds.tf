# Use a random string to make the parameter group name unique
resource "random_string" "db_param_suffix" {
  length  = 8
  special = false
  upper   = false
}



resource "random_id" "rds_suffix" {
  byte_length = 4
}

resource "aws_db_parameter_group" "db_parameter_group" {
  name   = "csye6225-mysql-params-${random_id.rds_suffix.hex}"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "csye6225-db-subnet-group-${random_id.rds_suffix.hex}"
  subnet_ids  = aws_subnet.private_subnet[*].id
  description = "Private subnets for RDS"
}


resource "random_password" "db_pass" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "db_pass" {
  name                    = var.Secrets_Name
  description             = "Database password for the RDS instance"
  kms_key_id              = aws_kms_key.secrets_key.arn
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_password_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_pass.id
  secret_string = jsonencode({ password = random_password.db_pass.result })
}


resource "aws_db_instance" "csye6225" {
  identifier             = "csye6225"
  engine                 = "mysql"
  engine_version         = "8.0"         # Explicitly set to 8.0
  instance_class         = "db.t3.micro" # Changed from t2.micro to t3.micro for compatibility
  username               = var.db_username
  password               = random_password.db_pass.result
  db_name                = var.db_name
  multi_az               = false
  publicly_accessible    = false
  allocated_storage      = 20
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  parameter_group_name   = aws_db_parameter_group.db_parameter_group.name
  skip_final_snapshot    = true
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.rds_kms_key.arn
}