

resource "aws_vpc" "vpc" {
  cidr_block       = var.cidr
  instance_tenancy = "default"

  tags = {
    Name = "${var.name}-vpc"
  }
}


resource "aws_subnet" "public_subs" {
  for_each          = var.public_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.name}-${each.key}"
  }
}

resource "aws_subnet" "private_subs" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.name}-${each.key}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "${var.name}-IGW" }
}

# Elastic IP
resource "aws_eip" "eip" {
  domain = "vpc"
  tags   = { Name = "${var.name}-EIP" }
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subs["pub1"].id
  tags          = { Name = "${var.name}-Nat-GW" }
}

# Route Tables
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = var.all_cidr
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.name}-pub-rt" }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = var.all_cidr
    gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "${var.name}-pri-rt" }
}

# Associations (public + private)
resource "aws_route_table_association" "public-RTA" {
  for_each       = aws_subnet.public_subs
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private-RTA" {
  for_each       = aws_subnet.private_subs
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private-rt.id
}

#creating keypair RSA key of size 4096 bits
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Creating private key
resource "local_file" "private-key" {
  content         = tls_private_key.key.private_key_pem
  filename        = "${var.name}-key.pem"
  file_permission = 440
}

# Creating public key 
resource "aws_key_pair" "public-key" {
  key_name   = "${var.name}-infra-key"
  public_key = tls_private_key.key.public_key_openssh
}

# #insert secret manager here
