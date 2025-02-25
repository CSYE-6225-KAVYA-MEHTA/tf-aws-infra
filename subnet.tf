resource "aws_subnet" "public_subnet" {
  count                   = var.subnet_count_public
  vpc_id                  = aws_vpc.csye6225_vpc.bad
  cidr_block              = var.CIDRS_Public[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.VPC_name}public_subnet${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = var.subnet_count_private
  vpc_id            = aws_vpc.csye6225_vpc.id
  cidr_block        = var.CIDRS_Private[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]


  tags = {
    Name = "${var.VPC_name}private_subnet${count.index + 1}"
  }
}
