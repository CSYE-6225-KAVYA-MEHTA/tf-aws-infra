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
  description = "Policy that grants both S3 access and CloudWatch permissions"
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
