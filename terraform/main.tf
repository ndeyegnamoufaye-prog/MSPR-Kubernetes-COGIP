# VPC
resource "aws_vpc" "mspr_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "mspr_igw" {
  vpc_id = aws_vpc.mspr_vpc.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

# Subnet public
resource "aws_subnet" "mspr_subnet" {
  vpc_id                  = aws_vpc.mspr_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-subnet"
    Project = var.project_name
  }
}

# Route Table
resource "aws_route_table" "mspr_rt" {
  vpc_id = aws_vpc.mspr_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mspr_igw.id
  }

  tags = {
    Name    = "${var.project_name}-rt"
    Project = var.project_name
  }
}

# Association Route Table
resource "aws_route_table_association" "mspr_rta" {
  subnet_id      = aws_subnet.mspr_subnet.id
  route_table_id = aws_route_table.mspr_rt.id
}

# Security Group
resource "aws_security_group" "mspr_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group MSPR COGIP"
  vpc_id      = aws_vpc.mspr_vpc.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # K3s API
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Communication interne cluster
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  # Sortie
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}

# VM Poste de travail
resource "aws_instance" "poste_travail" {
  ami                    = var.ami_id
  instance_type          = var.instance_type_master
  subnet_id              = aws_subnet.mspr_subnet.id
  vpc_security_group_ids = [aws_security_group.mspr_sg.id]
  key_name               = var.key_name

  root_block_device {
    volume_size = 40
    volume_type = "gp3"
  }

  tags = {
    Name    = "${var.project_name}-poste-travail"
    Project = var.project_name
    Role    = "poste-travail"
  }
}

# VM Control-plane K3s
resource "aws_instance" "control_plane" {
  ami                    = var.ami_id
  instance_type          = var.instance_type_master
  subnet_id              = aws_subnet.mspr_subnet.id
  vpc_security_group_ids = [aws_security_group.mspr_sg.id]
  key_name               = var.key_name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name    = "${var.project_name}-control-plane"
    Project = var.project_name
    Role    = "control-plane"
  }
}

# VM Worker 1
resource "aws_instance" "worker1" {
  ami                    = var.ami_id
  instance_type          = var.instance_type_worker
  subnet_id              = aws_subnet.mspr_subnet.id
  vpc_security_group_ids = [aws_security_group.mspr_sg.id]
  key_name               = var.key_name

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name    = "${var.project_name}-worker1"
    Project = var.project_name
    Role    = "worker"
  }
}

# VM Worker 2
resource "aws_instance" "worker2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type_worker
  subnet_id              = aws_subnet.mspr_subnet.id
  vpc_security_group_ids = [aws_security_group.mspr_sg.id]
  key_name               = var.key_name

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name    = "${var.project_name}-worker2"
    Project = var.project_name
    Role    = "worker"
  }
}



# Elastic IP pour l'Ingress
resource "aws_eip" "mspr_eip" {
  domain = "vpc"

  tags = {
    Name    = "${var.project_name}-eip"
    Project = var.project_name
  }
}