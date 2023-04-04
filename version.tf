terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.61.0"
    }
  }
}
#                        DATA SOURCE
data "aws_availability_zones" "az" {
  state = "available"
}