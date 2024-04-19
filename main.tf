provider "aws" {
  profile = "default"
  region = var.aws_region
}
terraform {
  required_providers {
    aws={
        version = "~>4.0"
    }
  }
}
terraform {
  backend "s3" {
    bucket = "bucketvk4"
    key    = "terraform.tfstate "  //file.tfstate  //terraform.tfstate  
    region = "ap-southeast-2"
  } 
}
resource "aws_vpc" "vpc2" {
    cidr_block = var.vpc_cidr
   enable_dns_hostnames = true
   tags = {
     Name = var.vpc_name
   }
}
resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.vpc2.id
  cidr_block = var.public_cidr
  availability_zone = var.availability_zone
  tags = {
    Name = var.subnet_name
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.vpc2.id
  tags={
    Name = var.igw_name
  }
}
resource "aws_route_table" "myrt" {
    vpc_id = aws_vpc.vpc2.id
    route  {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.IGW.id
    }
}
resource "aws_route_table_association" "RTA" {
  subnet_id = aws_subnet.subnet1.id
  route_table_id = aws_route_table.myrt.id
}
resource "aws_security_group" "SG" {
  vpc_id = aws_vpc.vpc2.id
  description = "allow traffic"
  ingress {
    from_port = "22"
    to_port = "22"
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
  }
  ingress {
    from_port = "80"
    to_port = "80"
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
  }
  tags = {
    Name = var.secgrp_name
  }
}
resource "aws_instance" "server" {
  ami = var.image_name
  subnet_id = aws_subnet.subnet1.id
  instance_type = var.instance_type
  key_name = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.SG.id]
  tags = {
    Name = var.instance_name
  }
  
}
