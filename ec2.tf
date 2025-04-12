# resource "aws_instance" "web_app_instance" {
#   ami                    = var.AMI
#   instance_type          = var.INSTANCE_TYPE
#   subnet_id              = aws_subnet.public_subnet[0].id
#   vpc_security_group_ids = [aws_security_group.app_security_group.id]

#   iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

#   root_block_device {
#     volume_size           = var.VOLUME_SIZE
#     volume_type           = "gp2"
#     delete_on_termination = true
#   }

#   disable_api_termination = false

#   user_data = <<-EOF
#     #!/bin/bash
#     # Remove any existing .env file in /opt/csye6225
#     #!/bin/bash
#     rm -f /opt/csye6225/.env
#     # Set environment variables for database configuration
#     echo "DB_HOST=${aws_db_instance.csye6225.address}" >> /opt/csye6225/.env
#     echo "DB_PORT=${aws_db_instance.csye6225.port}" >> /opt/csye6225/.env
#     echo "DB_DATABASE=${aws_db_instance.csye6225.db_name}" >> /opt/csye6225/.env
#     echo "DB_USERNAME=${var.db_username}" >> /opt/csye6225/.env
#     echo "DB_PASSWORD=${var.db_password}" >> /opt/csye6225/.env
#     echo "SERVER_PORT=8080" >> /opt/csye6225/.env
#     echo "S3_BUCKET=${aws_s3_bucket.webapp_bucket.id}" >> /opt/csye6225/.env
#     echo "AWS_REGION=${var.Region}" >> /opt/csye6225/.env

#     # Install and configure CloudWatch Agent
#     sudo apt-get update -y
#     sudo apt-get install -y amazon-cloudwatch-agent

#     # Create CloudWatch Agent configuration directory and file under /opt/aws
#     mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/
#     cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'CWAGENTCONFIG'
#     {
#       "agent": {
#         "metrics_collection_interval": 60,
#         "run_as_user": "root"
#       },
#       "logs": {
#         "logs_collected": {
#           "files": {
#             "collect_list": [
#               {
#                 "file_path": "/opt/csye6225/app.log",
#                 "log_group_name": "csye6225",
#                 "log_stream_name": "{instance_id}-app-logs",
#                 "retention_in_days": 7
#               }
#             ]
#           }
#         }
#       },
#       "metrics": {
#         "namespace": "CSYE6225/WebApp",
#         "metrics_collected": {
#           "statsd": {
#             "service_address": ":8125",
#             "metrics_collection_interval": 15
#           }
#         }
#       }
#     }
#     CWAGENTCONFIG

#     # Restart the CloudWatch Agent to apply the new configuration
#     systemctl daemon-reload
#     systemctl enable amazon-cloudwatch-agent
#     systemctl restart amazon-cloudwatch-agent

#     # Restart the web application service (assumes webapp is managed by systemd)
#     systemctl daemon-reload
#     systemctl restart webapp.service

#   EOF

#   depends_on = [aws_db_instance.csye6225]

#   tags = {
#     Name = "WebApp-Instance"
#   }
# }

# variable "AMI" {
#   description = "Machine image ID"
#   type        = string
# }

# variable "INSTANCE_TYPE" {
#   description = "Type of EC2 instance"
#   type        = string
# }

# variable "VOLUME_SIZE" {
#   description = "EBS volume size (in GB)"
#   type        = number
# }

# variable "db_username" {
#   description = "Database username"
#   type        = string
# }

# variable "db_password" {
#   description = "Database password"
#   type        = string
#   sensitive   = true
# }

# variable "db_name" {
#   description = "Database name"
#   type        = string
# }

# output "instance_public_ip" {
#   description = "Public IP of the EC2 instance"
#   value       = aws_instance.web_app_instance.public_ip
# }
