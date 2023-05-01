provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "myvpc" {
  cidr_block = var.aws_vpc_cidr
  tags = {
    "Name" = "${var.env}-vpc"
  }

}

/*

terraform {
  backend "s3" {
    bucket = "terraformstatefilesrepo"
    key    = "dev/statefile/terraform.tfstate"
    region = "ap-south-1"
    dynamodb_table = "terraform-state-lock"
  }
}
*/

/*
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = "terraform-state-lock-dynamo"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
 
  attribute {
    name = "LockID"
    type = "S"
  }
}
*/

module "myapp-subnet" {
  source              = "./modules/subnets"
  aws_vpc_subnet_cidr = var.aws_vpc_subnet_cidr
  myvpc_id            = aws_vpc.myvpc.id
  env                 = var.env
  avail_zone          = var.avail_zone

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
  name   = "chakra-sgs"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
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
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20230207.0-x86_64-gp2"]
  }
}

resource "aws_instance" "my_vm" {
  ami                         = data.aws_ami.example.id
  instance_type               = var.instance_type
  subnet_id                   = module.myapp-subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.chakra-sg.id]
  availability_zone           = var.avail_zone
  associate_public_ip_address = true
  key_name                    = "mykey"

  user_data = file(var.data)
  tags = {
    "Name" = "${var.env}-firstVM"
  }
}
