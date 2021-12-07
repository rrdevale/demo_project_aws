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

module "my-server" {
  source = "./modules/webserver"
  vpc_id = aws_vpc.demo_vpc.id
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  instance_type = var.instance_type
  public_key_location = var.public_key_location
  subnet_id = module.my-subnet.subnet
}
