# KMS Key for EC2 encryption
resource "aws_kms_key" "ec2_kms_key" {
  description             = "KMS key for encrypting EC2 volumes"
  deletion_window_in_days = 7
  rotation_period_in_days = 90
  enable_key_rotation     = true
  multi_region            = true
}

# KMS Key for RDS encryption
resource "aws_kms_key" "rds_kms_key" {
  description             = "KMS key for encrypting RDS instances"
  deletion_window_in_days = 7
  rotation_period_in_days = 90
  enable_key_rotation     = true
  multi_region            = true
}

# KMS Key for S3 bucket encryption
resource "aws_kms_key" "s3_kms_key" {
  description             = "KMS key for encrypting S3 buckets"
  deletion_window_in_days = 7
  rotation_period_in_days = 90
  enable_key_rotation     = true
  multi_region            = true
}

# KMS Key for Secrets Manager (for the database password and email credentials)
resource "aws_kms_key" "secrets_key" {
  description             = "KMS key for encrypting Secrets Manager secrets (DB password)"
  deletion_window_in_days = 7
  rotation_period_in_days = 90
  enable_key_rotation     = true
  multi_region            = true
}


