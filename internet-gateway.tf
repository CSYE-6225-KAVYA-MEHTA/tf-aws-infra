resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.csye6225_vpc.id
 
  tags = {
    Name = "${var.VPC_name}_internet_gateway"
  }
}