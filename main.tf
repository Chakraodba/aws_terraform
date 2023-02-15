provider "aws" {
  region     = "ap-south-1"
}

variable "aws_vpc_cidr" {
  type = list(object({
    cidr_block = string,
    name = string
}))
}
variable "tag_name" {}

resource "aws_vpc" "myvpc" {
    cidr_block = var.aws_vpc_cidr[0].cidr_block
    tags = {
      "Name" = var.aws_vpc_cidr[0].name
    }
  
}

resource "aws_subnet" "myvpc-subnet-public" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = var.aws_vpc_cidr[0].cidr_block
    availability_zone = "ap-south-1a"
    tags = {
      "Name" = var.aws_vpc_cidr[0].name
    }
  
}

data "aws_vpc" "defaultone" {
    default = true
}

resource "aws_subnet" "default-subnet-public" {
    vpc_id = data.aws_vpc.defaultone.id
    cidr_block = "172.31.16.0/28"
    availability_zone = "ap-south-1b"
    tags = {
      "Name" = "default-sub-pub"
    }
}
  
output "aws_vpc_id" {
  value = aws_vpc.myvpc.id
}