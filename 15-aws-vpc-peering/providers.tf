

provider "aws" {
  alias   = "primary" 
  region = var.aws_region_first
}

provider "aws" {
  alias   = "secondary"
  region = var.aws_region_second
}