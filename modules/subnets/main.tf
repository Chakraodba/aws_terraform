resource "aws_subnet" "myvpc-subnet-public" {
    vpc_id = var.myvpc_id
    cidr_block = var.aws_vpc_subnet_cidr
    availability_zone = var.avail_zone
    tags = {
      "Name" = "${var.env}-subnet"
    }
  
}

resource "aws_route_table" "myroute" {
  vpc_id = var.myvpc_id
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
  tags = {
    "Name" = "${var.env}-route"
  }
  
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = var.myvpc_id
  tags = {
    "Name" = "${var.env}-igw"
  }
}


resource "aws_route_table_association" "rt_associate" {
  subnet_id = aws_subnet.myvpc-subnet-public.id
  route_table_id = aws_route_table.myroute.id
  #replace = true
}
