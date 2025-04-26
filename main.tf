provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "protovision_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "protovision-vpc"
  }
}

# Create a public subnet
resource "aws_subnet" "protovision_subnet" {
  vpc_id                  = aws_vpc.protovision_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "protovision-subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "protovision_igw" {
  vpc_id = aws_vpc.protovision_vpc.id

  tags = {
    Name = "protovision-igw"
  }
}

# Create a Route Table
resource "aws_route_table" "protovision_route_table" {
  vpc_id = aws_vpc.protovision_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.protovision_igw.id
  }

  tags = {
    Name = "protovision-route-table"
  }
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "protovision_route_table_assoc" {
  subnet_id      = aws_subnet.protovision_subnet.id
  route_table_id = aws_route_table.protovision_route_table.id
}

# Create a Security Group
resource "aws_security_group" "protovision_sg" {
  name        = "protovision-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.protovision_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "protovision-sg"
  }
}

# Launch an EC2 instance
resource "aws_instance" "protovision_server" {
  ami                    = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI (may vary)
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.protovision_subnet.id
  vpc_security_group_ids = [aws_security_group.protovision_sg.id]

  tags = {
    Name = "protovision-ec2-instance"
  }
}
