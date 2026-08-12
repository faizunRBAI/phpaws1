# Fetch the latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Reuse the default VPC
data "aws_vpc" "default" {
  default = true
}

# Reuse default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security group: allow SSH (22) and HTTP (80)
resource "aws_security_group" "app" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = data.aws_vpc.default.id

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
    Name      = "${var.project_name}-sg"
    Project   = var.project_name
    ManagedBy = "udap"
  }
}

# EC2 Key Pair from platform secret
resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-keypair"
  public_key = var.ssh_public_key

  tags = {
    Project   = var.project_name
    ManagedBy = "udap"
  }
}

# EC2 instance
resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.app.id]
  subnet_id              = tolist(data.aws_subnets.default.ids)[0]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name      = "${var.project_name}-app"
    Project   = var.project_name
    ManagedBy = "udap"
  }
}

# Elastic IP for stable address
resource "aws_eip" "app" {
  instance = aws_instance.app.id
  domain   = "vpc"

  tags = {
    Name      = "${var.project_name}-eip"
    Project   = var.project_name
    ManagedBy = "udap"
  }
}
