resource "aws_vpc" "primary_vpc" {
  provider = aws.primary
  cidr_block = var.vpc_cidr[0]
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(var.tags, {
    Name = "primary_vpc"
  })
}

resource "aws_vpc" "secondary_vpc" {
  provider = aws.secondary
  cidr_block = var.vpc_cidr[1]
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(var.tags, {
    Name = "secondary_vpc"
  })
}