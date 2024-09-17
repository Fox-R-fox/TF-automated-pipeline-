provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "webapp_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create Internet Gateway
resource "aws_internet_gateway" "webapp_igw" {
  vpc_id = aws_vpc.webapp_vpc.id
}

# Create Route Table for Public Subnet
resource "aws_route_table" "webapp_public_rt" {
  vpc_id = aws_vpc.webapp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webapp_igw.id
  }
}

# Create Subnet (Public Subnet)
resource "aws_subnet" "webapp_public_subnet" {
  vpc_id            = aws_vpc.webapp_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true # Automatically assign public IP to instances
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "webapp_public_rt_assoc" {
  subnet_id      = aws_subnet.webapp_public_subnet.id
  route_table_id = aws_route_table.webapp_public_rt.id
}

# Security Group allowing SSH and HTTP
resource "aws_security_group" "webapp_sg" {
  vpc_id = aws_vpc.webapp_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role for EC2 Instances
resource "aws_iam_role" "ec2_codedeploy_role" {
  name = "EC2CodeDeployRole"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Inline policy with necessary permissions
resource "aws_iam_role_policy" "ec2_codedeploy_policy" {
  name = "EC2CodeDeployPolicy"
  role = aws_iam_role.ec2_codedeploy_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "codedeploy:*",
          "s3:Get*",
          "s3:List*",
          "ec2:Describe*",
          "cloudwatch:*",
          "logs:*"
        ],
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.ec2_codedeploy_role.name
}

# EC2 Instance for QA Environment
resource "aws_instance" "webapp_instance_qa" {
  ami             = "ami-0e86e20dae9224db8" # Example Ubuntu AMI
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.webapp_public_subnet.id
  security_groups = [aws_security_group.webapp_sg.id]

  key_name        = "fox"  # Replace with your EC2 Key Pair

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  user_data = <<EOF
#!/bin/bash
# Update the instance
sudo apt-get update -y

# Install Docker
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# Install the AWS CodeDeploy agent
sudo apt-get install -y ruby wget
cd /home/ubuntu
wget https://aws-codedeploy-us-east-2.s3.us-east-2.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto

# Start CodeDeploy agent
sudo service codedeploy-agent start
EOF

  tags = {
    Name = "WebApp-QA"
    fox  = "QA-EC2-Instance"  # Added for CodeDeploy identification
  }
}

# EC2 Instance for Live Environment
resource "aws_instance" "webapp_instance_live" {
  ami             = "ami-0e86e20dae9224db8" # Example Ubuntu AMI
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.webapp_public_subnet.id
  security_groups = [aws_security_group.webapp_sg.id]

  key_name        = "fox"  # Replace with your EC2 Key Pair

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  user_data = <<EOF
#!/bin/bash
# Update the instance
sudo apt-get update -y

# Install Docker
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# Install the AWS CodeDeploy agent
sudo apt-get install -y ruby wget
cd /home/ubuntu
wget https://aws-codedeploy-us-east-2.s3.us-east-2.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto

# Start CodeDeploy agent
sudo service codedeploy-agent start
EOF

  tags = {
    Name = "WebApp-Live"
    fox  = "Live-EC2-Instance"  # Added for CodeDeploy identification
  }
}
