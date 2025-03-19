resource "aws_instance" "web_app_instance" {
  ami           = var.AMI
  instance_type = var.INSTANCE_TYPE

  # Attach the security group
  vpc_security_group_ids = [aws_security_group.app_security_group.id]

  # Comment out IAM instance profile until you have permissions
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  # Make sure the EBS volume is terminated when the instance is terminated
  root_block_device {
    volume_size           = var.VOLUME_SIZE
    volume_type           = "gp2"
    delete_on_termination = true
  }

  # Disable accidental termination protection
  disable_api_termination = false

  # Ensure the EC2 instance is created within the custom VPC and subnet
  subnet_id = aws_subnet.public_subnet[0].id

  # User data script to configure MySQL database connection
  user_data = <<-EOF
    #!/bin/bash
    
    # Set environment variables for database configuration
    echo "DB_HOST=${aws_db_instance.csye6225.address}" >> /etc/environment
    echo "DB_PORT=${aws_db_instance.csye6225.port}" >> /etc/environment
    echo "DB_DATABASE=${aws_db_instance.csye6225.db_name}" >> /etc/environment
    echo "DB_USERNAME=${var.db_username}" >> /etc/environment
    echo "DB_PASSWORD=${var.db_password}" >> /etc/environment
    echo "SERVER_PORT=8080" >> /etc/environment
    echo "S3_BUCKET=${aws_s3_bucket.webapp_bucket.id}" >> /etc/environment
    
    # Apply environment variables
    source /etc/environment
    
    # Restart webapp service to apply changes
    systemctl daemon-reload
    systemctl restart webapp.service
  EOF

  # Make sure RDS instance is created before EC2 instance
  depends_on = [aws_db_instance.csye6225]

  tags = {
    Name = "WebApp-Instance"
  }
}


variable "AMI" {
  description = "machine image number"
  type        = string
}

variable "INSTANCE_TYPE" {
  description = "type of instance in ec2"
  type        = string
}

variable "VOLUME_SIZE" {
  description = "EBS volume size"
  type        = number
}

# Add these missing variables
variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
}