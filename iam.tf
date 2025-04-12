data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ec2_combined_role" {
  name = "csye6225_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "combined_policy" {
  name        = "csye6225_combined_policy"
  description = "Policy granting S3, CloudWatch, and KMS permissions for CSYE6225"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      // S3 permissions
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.webapp_bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.webapp_bucket.bucket}/*"
        ]
      },
      // CloudWatch Logs & Metrics permissions
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ],
        Resource = "*"
      },
      {
        Effect : "Allow",
        Action : [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        Resource : [
          aws_kms_key.ec2_kms_key.arn,
          aws_kms_key.rds_kms_key.arn,
          aws_kms_key.s3_kms_key.arn,
          aws_kms_key.secrets_key.arn
        ]
      }
    ]
  })
}



resource "aws_iam_role_policy_attachment" "attach_cw_policy" {
  role       = aws_iam_role.ec2_combined_role.name
  policy_arn = aws_iam_policy.combined_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "csye6225_instance_profile"
  role = aws_iam_role.ec2_combined_role.name
}

resource "aws_cloudwatch_log_group" "webapp_log_group" {
  name              = "csye6225"
  retention_in_days = 14
}


# EC2 KMS Policy
resource "aws_iam_policy" "ec2_kms_policy" {
  name        = "EC2KMSUsagePolicy"
  description = "Policy allowing EC2 resources to use the EC2 KMS key for encryption and decryption"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "EC2KMSUsage",
        Effect : "Allow",
        Action : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:DescribeKey"
        ],
        Resource : aws_kms_key.ec2_kms_key.arn
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "attach_ec2_kms_policy" {
  role       = aws_iam_role.ec2_combined_role.name
  policy_arn = aws_iam_policy.ec2_kms_policy.arn
}


# RDS KMS Policy
resource "aws_iam_policy" "rds_kms_policy" {
  name        = "RDSKMSUsagePolicy"
  description = "Policy allowing RDS to use the RDS KMS key for encryption and decryption"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "RDSKMSUsage",
        Effect : "Allow",
        Action : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource : aws_kms_key.rds_kms_key.arn
      }
    ]
  })
}

# S3 KMS Policy
resource "aws_iam_policy" "s3_kms_policy" {
  name        = "S3KMSUsagePolicy"
  description = "Policy allowing S3 to use the S3 KMS key for encryption and decryption"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "S3KMSUsage",
        Effect : "Allow",
        Action : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource : aws_kms_key.s3_kms_key.arn
      }
    ]
  })
}

# Secrets Manager KMS Policy
resource "aws_iam_policy" "secrets_kms_policy" {
  name        = "SecretsKMSUsagePolicy"
  description = "Policy granting permissions to decrypt secrets and encrypt using the Secrets Manager KMS key"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "SecretsKMSUsage",
        Effect : "Allow",
        Action : [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource : aws_kms_key.secrets_key.arn
      },
      {
        Sid : "SecretsManagerAccess",
        Effect : "Allow",
        Action : [
          "secretsmanager:CreateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutResourcePolicy",
          "secretsmanager:PutSecretValue",
          "secretsmanager:RestoreSecret",
          "secretsmanager:TagResource",
          "secretsmanager:UntagResource",
          "secretsmanager:UpdateSecret",
          "secretsmanager:DeleteResourcePolicy"
        ],
        Resource : aws_secretsmanager_secret.db_pass.arn
      }
    ]
  })
}

# Attach the Secrets Manager KMS Policy to the EC2 role
resource "aws_iam_role_policy_attachment" "attach_secrets_kms_policy" {
  role       = aws_iam_role.ec2_combined_role.name
  policy_arn = aws_iam_policy.secrets_kms_policy.arn
}

resource "aws_secretsmanager_secret_policy" "db_password_policy" {
  secret_arn = aws_secretsmanager_secret.db_pass.arn

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "AllowRootAndEC2Access",
        Effect : "Allow",
        Principal : {
          AWS : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.ec2_combined_role.name}"
          ]
        },
        Action : [
          "secretsmanager:CreateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutResourcePolicy",
          "secretsmanager:PutSecretValue",
          "secretsmanager:RestoreSecret",
          "secretsmanager:TagResource",
          "secretsmanager:UntagResource",
          "secretsmanager:UpdateSecret",
          "secretsmanager:DeleteResourcePolicy"
        ],
        Resource : "*"
      },
      {
        Sid : "DenyNonApprovedAccess",
        Effect : "Deny",
        Principal : "*",
        Action : [
          "secretsmanager:CreateSecret"
        ],
        Resource : "*",
        Condition : {
          StringNotEquals : {
            "aws:PrincipalArn" : [
              "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
              "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.ec2_combined_role.name}"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ec2_generate_datakey_policy" {
  name = "EC2GenerateDataKeyPolicy"
  role = aws_iam_role.ec2_combined_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowGenerateDataKeyForEC2",
        Effect = "Allow",
        Action = [
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext"
        ],
        Resource = "arn:aws:kms:us-east-1:699475940666:key/mrk-7a8a4ea9b758453e82ad0f23fa970673"
      }
    ]
  })
}
