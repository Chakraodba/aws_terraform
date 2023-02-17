provider "aws" {
  region     = "ap-south-1"
}

variable "aws_vpc_cidr" {}
variable "aws_vpc_subnet_cidr" {}
variable "env" {}
variable "avail_zone" {}


resource "aws_vpc" "myvpc" {
    cidr_block = var.aws_vpc_cidr
    tags = {
      "Name" = "{var.env}-vpc"
    }
  
}

resource "aws_subnet" "myvpc-subnet-public" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = var.aws_vpc_subnet_cidr
    availability_zone = var.avail_zone
    tags = {
      "Name" = "{var.env}-subnet"
    }
  
}
 
output "aws_vpc_id" {
  value = aws_vpc.myvpc.id
}