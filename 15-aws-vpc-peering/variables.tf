
variable "aws_region_first" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "eu-north-1"
}


variable "aws_region_second" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "eu-west-3"
}


variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = list(string)
  default     = ["10.0.0.0/16", "10.1.0.0/16"]
}

variable "subnet_cidr"{
  description = "The CIDR block for the subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.1.1.0/24"]
}

variable "instance_type" {
  description = "The type of the instance"
  type        = string
  default     = "t2.micro"
}

variable "primary_key_name" {
  description = "The name of the key pair for the primary VPC"
  type        = string
  default     = "vpc-peering-demo"
}

variable "secondary_key_name" {
  description = "The name of the key pair for the secondary VPC"
  type        = string
  default     = "vpc-peering-demo-west"
}


variable "tags" {
  type        = map(string)
  description = "Default tags to apply to all resources"
  default     = {
    ManagedBy = "Terraform"
   
    project = "vpc-peering-demo"
    environment = "dev"
    terraform = "true"
  }
}
