resource "aws_vpc" "csye6225_vpc" {
  cidr_block       = var.CIDR_Block
  instance_tenancy = "default"

  tags = {
    Name = var.VPC_name
  }
}