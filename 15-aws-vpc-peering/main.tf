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
  cidr_block = var.vpc_cidr[0]
  availability_zone = data.aws_availability_zones.primary.names[0]
  tags = merge(local.tags, {
    Name = "primary_subnet"
  })
}

resource "aws_subnet" "secondary" {
  provider = aws.secondary
  vpc_id = aws_vpc.secondary.id
  cidr_block = var.vpc_cidr[1]
  availability_zone = data.aws_availability_zones.secondary.names[0]
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
  peer_region = var.aws_region_second
  peer_owner_id = data.aws_caller_identity.secondary.account_id
  auto_accept   = false
  tags = merge(local.tags, {
    Name = "vpc_peering_connection"
    Side = "Requester"
  })
}

resource "aws_vpc_peering_connection_accepter" "vpc_peering_connection_accepter" {
  provider = aws.secondary

  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering_connection.id
  auto_accept               = true
  

  tags = merge(local.tags, {
    Name = "vpc_peering_connection_accepter"
    Side = "Accepter"
  })
}


resource "aws_route" "primary_to_secondary" {
  provider = aws.primary
  route_table_id = aws_route_table.primary.id

  destination_cidr_block    = aws_vpc.secondary.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering_connection.id
  depends_on = [aws_vpc_peering_connection_accepter.vpc_peering_connection_accepter]
}

resource "aws_route" "secondary_to_primary" {
  provider = aws.secondary
  route_table_id = aws_route_table.secondary.id

  destination_cidr_block    = aws_vpc.primary.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering_connection.id
  depends_on = [aws_vpc_peering_connection_accepter.vpc_peering_connection_accepter]
}


resource "aws_security_group" "primary" {
  provider = aws.primary
  vpc_id = aws_vpc.primary.id
  name = "primary_sg"
  description = "Security group for primary VPC"
  tags = merge(local.tags, {
    Name = "primary_sg"
  })

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow ICMP from secondary VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr[1]]
  }

  ingress {
    description = "Allow traffic from secondary VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr[1]]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# secondary security group 

resource "aws_security_group" "secondary" {
  provider = aws.secondary
  vpc_id = aws_vpc.secondary.id
  name = "secondary_sg"
  description = "Security group for secondary VPC"
  tags = merge(local.tags, {
    Name = "secondary_sg"
  })

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow ICMP from primary VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr[0]]
  }

  ingress {
    description = "Allow traffic from primary VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr[0]]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_instance" "primary" {
  provider = aws.primary
  ami = data.aws_ami.primary.id
  instance_type = var.instance_type
  key_name = var.primary_key_name
  subnet_id = aws_subnet.primary.id
  vpc_security_group_ids = [aws_security_group.primary.id]
  user_data= local.primary_user_data
  depends_on = [aws_vpc_peering_connection_accepter.vpc_peering_connection_accepter]

  tags = merge(local.tags, {
    Name = "primary_instance"
  })
}


resource "aws_instance" "secondary" {
  provider = aws.secondary
  ami = data.aws_ami.secondary.id
  instance_type = var.instance_type
  key_name = var.secondary_key_name
  subnet_id = aws_subnet.secondary.id
  vpc_security_group_ids = [aws_security_group.secondary.id]
  user_data= local.secondary_user_data
  depends_on = [aws_vpc_peering_connection_accepter.vpc_peering_connection_accepter]
    

  tags = merge(local.tags, {
    Name = "secondary_instance"
  })
}


