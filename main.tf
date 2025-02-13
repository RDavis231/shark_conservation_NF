# Create a VPC for Shark Conservation Blog
resource "aws_vpc" "shark_conservation_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "shark_conservation_vpc"
  }
}

# Public Subnet 1
resource "aws_subnet" "shark_conservation_public_1" {
  vpc_id                  = aws_vpc.shark_conservation_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "shark_conservation_public_1"
  }
}

# Public Subnet 2
resource "aws_subnet" "shark_conservation_public_2" {
  vpc_id                  = aws_vpc.shark_conservation_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "shark_conservation_public_2"
  }
}

# Private Subnet 1
resource "aws_subnet" "shark_conservation_private_1" {
  vpc_id            = aws_vpc.shark_conservation_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "shark_conservation_private_1"
  }
}

# Private Subnet 2
resource "aws_subnet" "shark_conservation_private_2" {
  vpc_id            = aws_vpc.shark_conservation_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "shark_conservation_private_2"
  }
}

# Internet Gateway for Public Subnets
resource "aws_internet_gateway" "shark_conservation_igw" {
  vpc_id = aws_vpc.shark_conservation_vpc.id

  tags = {
    Name = "shark_conservation_igw"
  }
}

# Public Route Table
resource "aws_route_table" "shark_conservation_public_rt" {
  vpc_id = aws_vpc.shark_conservation_vpc.id

  route {
    cidr_block = "0.0.0.0/0" # Route all outbound traffic to the internet
    gateway_id = aws_internet_gateway.shark_conservation_igw.id
  }

  tags = {
    Name = "shark_conservation_public_rt"
  }
}

# Private Route Table (No NAT, No Internet Access)
resource "aws_route_table" "shark_conservation_private_rt" {
  vpc_id = aws_vpc.shark_conservation_vpc.id

  tags = {
    Name = "shark_conservation_private_rt"
  }
}

# Associate Public Route Table with Public Subnets
resource "aws_route_table_association" "shark_conservation_public_1_assoc" {
  subnet_id      = aws_subnet.shark_conservation_public_1.id
  route_table_id = aws_route_table.shark_conservation_public_rt.id
}

resource "aws_route_table_association" "shark_conservation_public_2_assoc" {
  subnet_id      = aws_subnet.shark_conservation_public_2.id
  route_table_id = aws_route_table.shark_conservation_public_rt.id
}

# Associate Private Route Table with Private Subnets (No Internet Access)
resource "aws_route_table_association" "shark_conservation_private_1_assoc" {
  subnet_id      = aws_subnet.shark_conservation_private_1.id
  route_table_id = aws_route_table.shark_conservation_private_rt.id
}

resource "aws_route_table_association" "shark_conservation_private_2_assoc" {
  subnet_id      = aws_subnet.shark_conservation_private_2.id
  route_table_id = aws_route_table.shark_conservation_private_rt.id
}
