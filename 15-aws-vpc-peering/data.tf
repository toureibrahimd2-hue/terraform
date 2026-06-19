data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


data "aws_availability_zones" "primary" {
  provider = aws.primary
  state = "available"
}

data "aws_availability_zones" "secondary" {
  provider = aws.secondary
  state = "available"
}

data "aws_ami" "primary" {
  most_recent = true
  provider = aws.primary
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  
}

data "aws_ami" "secondary" {
  most_recent = true
  provider = aws.secondary
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}



data "aws_caller_identity" "secondary" {
  provider = aws.secondary
}



