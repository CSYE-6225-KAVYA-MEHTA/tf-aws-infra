# Load Balancer Security Group: Allows HTTP/HTTPS from anywhere
resource "aws_security_group" "lb_security_group" {
  name        = "lb-security-group"
  description = "Security group for load balancer"
  vpc_id      = aws_vpc.csye6225_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Application Security Group: Ingress only from the LB security group for SSH and app traffic
resource "aws_security_group" "app_security_group" {
  name   = "app-security-group"
  vpc_id = aws_vpc.csye6225_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.lb_security_group.id]
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Database Security Group for RDS remains unchanged
resource "aws_security_group" "db_security_group" {
  name        = "db-security-group"
  description = "Security group for RDS instances"
  vpc_id      = aws_vpc.csye6225_vpc.id

  # Allow inbound traffic from the application security group to the MySQL port
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "database-security-group"
  }
}




# resource "aws_security_group" "app_security_group" {
#   name   = "app-security-group"
#   vpc_id = aws_vpc.csye6225_vpc.id # Ensure this is the VPC you created with Terraform

#   # Ingress rules for allowing incoming traffic
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # Allow SSH access from anywhere
#   }

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # Allow HTTP access from anywhere
#   }

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS access from anywhere
#   }

#   ingress {
#     from_port   = 8080
#     to_port     = 8080
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # Allow app access from anywhere
#   }

#   # Egress rule: Allow all outbound traffic
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }


# # Database Security Group for RDS
# resource "aws_security_group" "db_security_group" {
#   name        = "db-security-group"
#   description = "Security group for RDS instances"
#   vpc_id      = aws_vpc.csye6225_vpc.id

#   # Allow inbound traffic from the application security group to the MySQL port
#   ingress {
#     from_port       = 3306 # MySQL port
#     to_port         = 3306 # MySQL port
#     protocol        = "tcp"
#     security_groups = [aws_security_group.app_security_group.id]
#   }

#   # Allow all outbound traffic
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "database-security-group"
#   }
# }



