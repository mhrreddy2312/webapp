resource "aws_vpc" "main" {
  cidr_block       = "172.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "my-initial-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}


resource "aws_route_table" "example" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "example"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "initial-subnet"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.example.id
}


resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 10000
    protocol         = "tcp"
    cidr_blocks      = ["2.120.164.105/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}


resource "aws_flow_log" "example" {
  log_destination      = aws_s3_bucket.example.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
}

resource "aws_s3_bucket" "example" {
  bucket = "vpc-flow-logs-inital"

}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Jenkins-10072021"]
  }


  owners = ["268431047561"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.xlarge"
  vpc_security_group_ids =[aws_security_group.allow_tls.id]
  key_name= aws_key_pair.deployer.key_name
  subnet_id= aws_subnet.main.id

tags = {
    Name = "my-initial-ec2"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key-1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfwClE4VKRLATThJKArqJqzq4iOtv+HozpuS6Ikx799YPLUs5MLb/4+S+ErgCDGMd7Q2nlMFkcoFWjTOlPHonD9AdnBtBn81Bj0QkzJqrN5H9pZWZtzMV459+UuA1ExrZvZNTCUheQy/RG+/9cclNtzOf8bodFEfplSAM1VNL1BRIs8btm38FJ8Ico8TkTRNgKXaSTkJO+mY4U4ByUtOREQSSASY7Zdk0IKijxL31A2018me1N6YJppffkcKGXMwkdonQPPxR5hVgAgg8SGBEa7oXxICW4Qx9sFWpUEeoHwavIRPOgH1G495+VRdKGHVPi9w+iDHxGHRXhkZQDfUBb KPMG"
}

