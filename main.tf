provider "aws" {
    region = "us-east-2"
}

#Create VPC
resource "aws_vpc" "demo_vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}
module "my-subnet" {
  source = "./modules/subnet"
  avail_zone = var.avail_zone
  subnet_cidr_block = var.subnet_cidr_block
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.demo_vpc.id 
  default_route_table_id = aws_vpc.demo_vpc.default_route_table_id
  }
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

resource "aws_key_pair" "demo-key" {
  key_name      = "server-key"
  public_key    = "${file(var.public_key_location)}"
}

resource "aws_instance" "webserver" {
    #ami              = data.aws_ami.latest-ubuntu-linux-image.id
    ami                         = "ami-0629230e074c580f2"
    instance_type               = var.instance_type
    subnet_id                   = module.my-subnet.subnet
    vpc_security_group_ids      = [aws_default_security_group.default-sg.id]
    availability_zone           = var.avail_zone
    associate_public_ip_address = true
    #key_name                    = "new_key"
    key_name                    = aws_key_pair.demo-key.id

    tags = {
      Name = "${var.env_prefix}-server"
  }
}



