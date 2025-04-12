resource "aws_launch_template" "csye6225_asg" {
  name_prefix   = "csye6225_asg"
  image_id      = var.AMI
  instance_type = var.INSTANCE_TYPE
  key_name      = "csye6225-key"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app_security_group.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash

    sudo apt-get update -y
    sudo snap install aws-cli --classic
    sudo apt get install -y jq
    # Remove any existing .env file in /opt/csye6225
    rm -f /opt/csye6225/.env

    
    # Set environment variables for database configuration
    echo "DB_HOST=${aws_db_instance.csye6225.address}" >> /opt/csye6225/.env
    echo "DB_PORT=${aws_db_instance.csye6225.port}" >> /opt/csye6225/.env
    echo "DB_DATABASE=${aws_db_instance.csye6225.db_name}" >> /opt/csye6225/.env
    echo "DB_USERNAME=${var.db_username}" >> /opt/csye6225/.env




    # Retrieve the database password from AWS Secrets Manager
    DB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${var.Secrets_Name} --query 'SecretString' --output text --region ${var.Region} | jq -r '.password')
    echo "DB_PASSWORD=$DB_PASSWORD" >> /opt/csye6225/.env

    echo "SERVER_PORT=8080" >> /opt/csye6225/.env
    echo "S3_BUCKET=${aws_s3_bucket.webapp_bucket.id}" >> /opt/csye6225/.env
    echo "AWS_REGION=${var.Region}" >> /opt/csye6225/.env

    # Install and configure CloudWatch Agent
    sudo apt-get update -y
    sudo apt-get install -y amazon-cloudwatch-agent

    # Create CloudWatch Agent configuration directory and file
    mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/
    cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'CWAGENTCONFIG'
    {
      "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "root"
      },
      "logs": {
        "logs_collected": {
          "files": {
            "collect_list": [
              {
                "file_path": "/opt/csye6225/app.log",
                "log_group_name": "csye6225",
                "log_stream_name": "{instance_id}-app-logs",
                "retention_in_days": 7
              }
            ]
          }
        }
      },
      "metrics": {
        "namespace": "CSYE6225/WebApp",
        "metrics_collected": {
          "statsd": {
            "service_address": ":8125",
            "metrics_collection_interval": 15
          }
        }
      }
    }
    CWAGENTCONFIG

    # Restart the CloudWatch Agent to apply the new configuration
    systemctl daemon-reload
    systemctl enable amazon-cloudwatch-agent
    systemctl restart amazon-cloudwatch-agent

    # Restart the web application service (assumes webapp.service is properly defined)
    systemctl daemon-reload
    systemctl restart webapp.service

    # Optional delays to ensure service stability
    sleep 5
    systemctl daemon-reload
    sleep 5
    systemctl restart webapp.service
  EOF
  )
}
