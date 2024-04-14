terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
#Create a VPC
resource "aws_vpc" "myvpc"{
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "MyVPC"
    }
}

# 2: Create a public subnet
resource "aws_subnet" "PublicSubnet"{
    vpc_id = aws_vpc.myvpc.id
    availability_zone = "us-east-1a"
    cidr_block = "10.0.1.0/24"
}

#3 : create a private subnet
resource "aws_subnet" "PrivSubnet"{
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = true

}

# 4 : create IGW
resource "aws_internet_gateway" "myIgw"{
    vpc_id = aws_vpc.myvpc.id
}

 #5 : route Tables for public subnet
resource "aws_route_table" "PublicRT"{
    vpc_id = aws_vpc.myvpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myIgw.id
    }
}
 

 #6 : route table association public subnet 
resource "aws_route_table_association" "PublicRTAssociation"{
    subnet_id = aws_subnet.PublicSubnet.id
    route_table_id = aws_route_table.PublicRT.id
}

#7 : creating EC2 Instance
resource "aws_instance" "master_node" {
  ami           = "ami-080e1f13689e07408"
  instance_type = "t2.micro"
  key_name = "tayo-key-pair"
 # security_groups = [aws_security_group.instance_security_group.id]
  tags = {
    Name = "master-node"
  }
}

resource "aws_db_instance" "instance_name" {
  allocated_storage      = 10
  db_name              = "lamis"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t3.micro"
  username               = "root"
  password               = "root1234"
  publicly_accessible    = true
  parameter_group_name   = "default.postgres16"
  skip_final_snapshot    = true
}

# resource "aws_s3_bucket" "my_bucket" {
#   bucket = "my-unique-bucket-name1uh77juun"
#   acl    = "private"

#   tags = {
#     Environment = "Dev"
#   }
# }