provider "aws" {
  region     = "ap-south-1"
}

resource "aws_vpc" "myvpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      "Name" = "Terra-vpc"
    }
  
}

resource "aws_subnet" "myvpc-subnet-public" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1a"
    tags = {
      "Name" = "terra-vpc-sub-pub"
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