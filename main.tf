provider "aws" {
  region     = "ap-south-1"
}

variable "aws_vpc_cidr" {}
variable "aws_vpc_subnet_cidr" {}
variable "env" {}
variable "avail_zone" {}
variable "my_ip" {}
variable "instance_type" {}
variable "data" {}


resource "aws_vpc" "myvpc" {
    cidr_block = var.aws_vpc_cidr
    tags = {
      "Name" = "${var.env}-vpc"
    }
  
}

resource "aws_subnet" "myvpc-subnet-public" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = var.aws_vpc_subnet_cidr
    availability_zone = var.avail_zone
    tags = {
      "Name" = "${var.env}-subnet"
    }
  
}


resource "aws_route_table" "myroute" {
  vpc_id = aws_vpc.myvpc.id
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
  tags = {
    "Name" = "${var.env}-route"
  }
  
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    "Name" = "${var.env}-igw"
  }
}


resource "aws_route_table_association" "rt_associate" {
  subnet_id = aws_subnet.myvpc-subnet-public.id
  route_table_id = aws_route_table.myroute.id
  #replace = true
}

/*
resource "aws_default_route_table" "default_rt_table" {
  default_route_table_id = aws_vpc.myvpc.default_route_table_id
   route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
  tags = {
    "Name" = "${var.env}-route"
  }
  
}
*/

resource "aws_security_group" "chakra-sg" {
  name = "chakra-sgs"
  vpc_id = aws_vpc.myvpc.id

  ingress  {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }

   ingress  {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }
  ingress  {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }
  ingress  {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }

   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  

  tags = {
    "Name" = "${var.env}-sg"
  }
  
}

data "aws_ami" "example" {
  most_recent      = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20230207.0-x86_64-gp2"]
  } 
}

resource "aws_instance" "my_vm" {
  ami = data.aws_ami.example.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.myvpc-subnet-public.id
  vpc_security_group_ids = [aws_security_group.chakra-sg.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = "mykey"

  user_data = file(var.data)
  tags = {
    "Name" = "${var.env}-firstVM"
  }
}

output "aws_vpc_id" {
  value = aws_vpc.myvpc.id
}

output "pub_ip" {
  value = aws_instance.my_vm.public_ip
}