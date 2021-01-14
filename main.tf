
resource "aws_vpc" "master_vpc" {
  provider             = aws.useast1
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "Production"
  }
}
resource "aws_vpc" "slave_vpc" {
  provider             = aws.uswest2
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "Production"
  }
}

resource "aws_internet_gateway" "master-igw" {
  vpc_id   = aws_vpc.master_vpc.id
  provider = aws.useast1
}

resource "aws_internet_gateway" "slave-igw" {
  vpc_id   = aws_vpc.slave_vpc.id
  provider = aws.uswest2
}

#Get all available AZ's in VPC for East Region.
data "aws_availability_zones" "azs" {
  provider = aws.useast1
  state    = "available"
}
#Create subnet #1 in us-east-1
resource "aws_subnet" "subnet-1-east" {
  provider          = aws.useast1
  vpc_id            = aws_vpc.master_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.azs.names[0]
  #availability_zone = element(data.aws_availability_zones.azs.names, 0)
}
#Create subnet #2 in us-east-2
resource "aws_subnet" "subnet-2-east" {
  provider          = aws.useast1
  vpc_id            = aws_vpc.master_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.azs.names[1]
}
#Create subnet #1 in us-west-2
resource "aws_subnet" "subnet-1-oregon" {
  provider   = aws.uswest2
  vpc_id     = aws_vpc.slave_vpc.id
  cidr_block = "192.168.1.0/24"
}
#Initiate vpc peering connection from us-east-1
resource "aws_vpc_peering_connection" "master_slave" {
  provider    = aws.useast1
  peer_region = var.uswest2
  peer_vpc_id = aws_vpc.slave_vpc.id
  vpc_id      = aws_vpc.master_vpc.id
}
#Accept vpc peering on us-west-2 from us-east-1
resource "aws_vpc_peering_connection_accepter" "master-slave" {
  provider                  = aws.uswest2
  vpc_peering_connection_id = aws_vpc_peering_connection.master_slave.id
  auto_accept               = true
}
#Create vpc peering route table
resource "aws_route_table" "master_rt" {
  provider = aws.useast1
  vpc_id   = aws_vpc.master_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.master-igw.id
  }
  route {
    cidr_block                = "192.168.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.master_slave.id
  }
  lifecycle {
    ignore_changes = all
  }
}
#overwrite default vpc route table with peering route table.
resource "aws_main_route_table_association" "default_master_rt" {
  provider       = aws.useast1
  vpc_id         = aws_vpc.master_vpc.id
  route_table_id = aws_route_table.master_rt.id
}
#Create vpc peering route table
resource "aws_route_table" "slave_rt" {
  provider = aws.uswest2
  vpc_id   = aws_vpc.slave_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.slave-igw.id
  }
  route {
    cidr_block                = "10.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.master_slave.id
  }
  lifecycle {
    ignore_changes = all
  }
}
#overwrite default vpc route table with peering route table.
resource "aws_main_route_table_association" "default_slave_rt" {
  provider       = aws.uswest2
  vpc_id         = aws_vpc.slave_vpc.id
  route_table_id = aws_route_table.slave_rt.id
}