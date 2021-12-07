#Create subnet 
resource "aws_subnet" "demo-subnet-1" {
  vpc_id = var.vpc_id 
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
      Name = "${var.env_prefix}-subnet-1"
  }
}

#Create Internet Gateway and associate with VPC
resource "aws_internet_gateway" "demo-igw" {
  vpc_id = var.vpc_id 
  tags = {
      Name = "${var.env_prefix}-igw"
  }
}



#Associate default route table to VPC
resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = var.default_route_table_id 
  route  {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.demo-igw.id
  }
  tags = {
      Name = "${var.env_prefix}-main-rtb"
  }

}