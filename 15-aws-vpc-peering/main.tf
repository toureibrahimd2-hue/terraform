resource "aws_vpc" "primary" {
  provider = aws.primary
  cidr_block = var.vpc_cidr[0]
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(local.tags, {
    Name = "primary_vpc"
  })
}

resource "aws_vpc" "secondary" {
  provider = aws.secondary
  cidr_block = var.vpc_cidr[1]
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(local.tags, {
    Name = "secondary_vpc"
  })
}


resource "aws_subnet" "primary" {
  provider = aws.primary
  vpc_id = aws_vpc.primary.id
  cidr_block = var.subnet_cidr[0]
  availability_zone = data.availability_zones.primary.names[0]
  tags = merge(local.tags, {
    Name = "primary_subnet"
  })
}

resource "aws_subnet" "secondary" {
  provider = aws.secondary
  vpc_id = aws_vpc.secondary.id
  cidr_block = var.subnet_cidr[1]
  availability_zone = data.availability_zones.secondary.names[0]
  tags = merge(local.tags, {
    Name = "secondary_subnet"
  })
}


resource "aws_internet_gateway" "primary" {
  provider = aws.primary
  vpc_id = aws_vpc.primary.id
  tags = merge(local.tags, {
    Name = "primary_igw"
  })
}

resource "aws_internet_gateway" "secondary" {
  provider = aws.secondary
  vpc_id = aws_vpc.secondary.id
  tags = merge(local.tags, {
    Name = "secondary_igw"
  })
}


resource "aws_route_table" "primary" {
  provider = aws.primary
  vpc_id = aws_vpc.primary.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary.id
  }
  tags = merge(local.tags, {
    Name = "primary_route_table"
  })
}

resource "aws_route_table" "secondary" {
  provider = aws.secondary
  vpc_id = aws_vpc.secondary.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary.id
  }
  tags = merge(local.tags, {
    Name = "secondary_route_table"
  })
}

resource "aws_route_table_association" "primary" {
  provider = aws.primary
  subnet_id = aws_subnet.primary.id
  route_table_id = aws_route_table.primary.id
}

resource "aws_route_table_association" "secondary" {
  provider = aws.secondary
  subnet_id = aws_subnet.secondary.id
  route_table_id = aws_route_table.secondary.id
}



resource "aws_vpc_peering_connection" "vpc_peering_connection" {
  provider = aws.primary
  vpc_id      = aws_vpc.primary.id
  peer_vpc_id = aws_vpc.secondary.id
  peer_owner_id = data.aws_caller_identity.secondary.account_id
  auto_accept   = false
  tags = merge(local.tags, {
    Name = "vpc_peering_connection"
    Side = "Requester"
  })
}

resource "aws_vpc_peering_connection_options" "vpc_peering_connection_options" {
  provider = aws.secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering_connection.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  tags = merge(local.tags, {
    Name = "vpc_peering_connection_options"
    Side = "Accepter"
  })

}


