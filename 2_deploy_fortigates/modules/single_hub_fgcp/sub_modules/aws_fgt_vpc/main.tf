##############################################################################################################
# Create VPC SEC and Subnets
# - VPC security
# - Subnets AZ1: mgmt, public, private, TGW, GWLB
# - Subnets AZ1: mgmt, public, private, TGW, GWLB
##############################################################################################################
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

# IGW
resource "aws_internet_gateway" "igw-vpc" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

# Subnets AZ1
resource "aws_subnet" "subnet-az1-public" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.subnet_az1_public_cidr
  availability_zone = var.region["az1"]
  tags = {
    Name = "${var.prefix}-subnet-az1-public"
  }
}

resource "aws_subnet" "subnet-az1-private" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.subnet_az1_private_cidr
  availability_zone = var.region["az1"]
  tags = {
    Name = "${var.prefix}-subnet-az1-private"
  }
}

resource "aws_subnet" "subnet-az1-bastion" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.subnet_az1_bastion_cidr
  availability_zone = var.region["az1"]
  tags = {
    Name = "${var.prefix}-subnet-az1-bastion"
  }
}
