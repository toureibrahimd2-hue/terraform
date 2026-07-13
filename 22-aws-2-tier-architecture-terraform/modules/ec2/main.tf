# EC2 Module - Main Configuration

# Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# IAM Role for EC2 Instance to access Secrets Manager
resource "aws_iam_role" "web" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-ec2-role"
    Environment = var.environment
  }
}

# IAM Policy to allow reading database secret from Secrets Manager
resource "aws_iam_policy" "secrets_read" {
  name        = "${var.project_name}-${var.environment}-secrets-policy"
  description = "Policy to allow EC2 to read database credentials from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [var.db_secret_arn]
      }
    ]
  })
}

# Attach IAM Policy to Role
resource "aws_iam_role_policy_attachment" "web_secrets" {
  role       = aws_iam_role.web.name
  policy_arn = aws_iam_policy.secrets_read.arn
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "web" {
  name = "${var.project_name}-${var.environment}-instance-profile"
  role = aws_iam_role.web.name
}

# EC2 Instance
resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.web_security_group_id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.web.name

  user_data = templatefile("${path.module}/templates/user_data.sh", {
    db_host       = var.db_host
    db_username   = var.db_username
    db_name       = var.db_name
    db_secret_arn = var.db_secret_arn
    aws_region    = var.aws_region
  })

  tags = {
    Name        = "${var.project_name}-web-server"
    Environment = var.environment
  }
}