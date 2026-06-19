
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
