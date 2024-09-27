resource "aws_vpc" "lila_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "lila-vpc"
  }
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "MainVPC"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr_1
  availability_zone = var.public_availability_zone_1

  tags = {
    Name = "PublicSubnet1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr_2
  availability_zone = var.public_availability_zone_2

  tags = {
    Name = "PublicSubnet2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_1
  availability_zone = var.private_availability_zone_1

  tags = {
    Name = "PrivateSubnet1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_2
  availability_zone = var.private_availability_zone_2

  tags = {
    Name = "PrivateSubnet2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "MainIGW"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table_association" "public_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_association_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_association_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "lila_mongo_sg" {
  name_prefix = "lila_mongo_sg"
  description = "Security group for MongoDB"
  vpc_id      = aws_vpc.main.id 

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lambda-sg"
  }
}

resource "aws_security_group" "docdb_sg" {
  name        = "docdb-sg"
  description = "Security Group for DocumentDB"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "docdb-sg"
  }
}

resource "aws_security_group" "codebuild_sg" {
  name_prefix = "codebuild_sg"
  description = "Security group for CodeBuild"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "CodeBuildSecurityGroup"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "lila_nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id    = aws_subnet.public_subnet_1.id
  tags = {
    Name = "Lila NAT Gateway"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.lila_nat_gateway.id
  }

  tags = {
    Name = "Private Route Table"
  }
}

