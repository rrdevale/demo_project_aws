provider "aws" {
    region = "us-east-2"
}

variable  vpc_cidr_block {}
variable  subnet_cidr_block {}
variable  avail_zone {}
variable  env_prefix {}

variable instance_type {}
variable  public_key_location {}

#Create VPC
resource "aws_vpc" "demo_vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

#Create subnet 
resource "aws_subnet" "demo-subnet-1" {
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
      Name = "${var.env_prefix}-subnet-1"
  }
}


#Create custom route table and attach with internet gateway
/*resource "aws_route_table" "demo-route-table" {
  vpc_id = aws_vpc.demo_vpc.id

  route  {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.demo-igw.id
  }
  tags = {
      Name = "${var.env_prefix}-rtb"
  }
}

#Associate route table with subnet
resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id = aws_subnet.demo-subnet-1.id
  route_table_id = aws_route_table.demo-route-table.id
}*/

#Create Internet Gateway and associate with VPC
resource "aws_internet_gateway" "demo-igw" {
  vpc_id = aws_vpc.demo_vpc.id
  tags = {
      Name = "${var.env_prefix}-igw"
  }
}



#Associate default route table to VPC
resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.demo_vpc.default_route_table_id
  route  {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.demo-igw.id
  }
  tags = {
      Name = "${var.env_prefix}-main-rtb"
  }

}

#Create security group for EC2 instance
/*resource "aws_security_group" "demo-sg" {
  name = "demo-SG"
  vpc_id = aws_vpc.demo_vpc.id

  ingress  {
      from_port  = 22
      to_port    = 22
      protocol   = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress  {
      from_port  = 8080
      to_port    = 8080
      protocol   = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"                #Any protocol
      cidr_blocks      = ["0.0.0.0/0"]  
      prefix_list_ids = []
  }
  tags = {
      Name = "${var.env_prefix}-demo-sg"
  }
}*/

#To use default security group
resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.demo_vpc.id
  ingress  {
      from_port  = 22
      to_port    = 22
      protocol   = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress  {
      from_port  = 8080
      to_port    = 8080
      protocol   = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"      /*any protocol*/
      cidr_blocks      = ["0.0.0.0/0"]  
      prefix_list_ids = []
 }
 tags = {
      Name = "${var.env_prefix}-default-sg"
  }

}

/*data "aws_ami" "latest-ubuntu-linux-image" {
  most_recent   = true
  owners        = ["099720109477"]

  filter {
    name    = "name"
    values  = ["ubuntu/images/hvm-ssd/ubuntu-focal-*-amd64*"]
  }

  filter {
    name    = "virtualization-type"
    values  = ["hvm"]
  }
}

output "aws_ami_id" {
  value = data.aws_ami.latest-ubuntu-linux-image.id
}*/

resource "aws_key_pair" "demo-key" {
  key_name      = "server-key"
  public_key    = "${file(var.public_key_location)}"
}

resource "aws_instance" "webserver" {
    #ami              = data.aws_ami.latest-ubuntu-linux-image.id
    ami                         = "ami-0629230e074c580f2"
    instance_type               = var.instance_type
    subnet_id                   = aws_subnet.demo-subnet-1.id
    vpc_security_group_ids      = [aws_default_security_group.default-sg.id]
    availability_zone           = var.avail_zone
    associate_public_ip_address = true
    #key_name                    = "new_key"
    key_name                    = aws_key_pair.demo-key.id

    /*user_data = <<EOF
                    #!/bin/bash
                    sudo apt update && sudo apt install docker.io -y
                    sudo usermod -aG docker ubuntu
                    docker run -itd -p 8080:80 nginx:1.18
                EOF*/

    user_data = file("entry-script.sh")
    tags = {
      Name = "${var.env_prefix}-server"
  }
}

output "ec2_public_ip" {
  value = aws_instance.webserver.public_ip
}

