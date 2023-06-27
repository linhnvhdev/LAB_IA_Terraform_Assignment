# Use the Ubuntu 18.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "main" {
  ami           = data.aws_ami.ubuntu.id
  instance_type =  "t2.micro" 
  subnet_id     = var.main_subnet_id
  count         =  1 

  root_block_device {
      encrypted = true
  }

  metadata_options {
    http_tokens = "required"
  }

  associate_public_ip_address = true

  tags = {
    Name = var.name
  }
}

# Security Groups

resource "aws_security_group" "all_ports_to_all" {
  name  = "${var.name}-all_ports_to_all"
  description = "Allow inbound and outbound from all port"
  count =  1 

  vpc_id = var.vpc_id

  ingress {
    description = "Allow inbound traffic from all port"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.vpc_cidr_v4]
  }

  egress { #update all egress cidr to vpc cidr
    description = "Allow outbound traffic to all port within vpc"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.vpc_cidr_v4]
  }

  egress {
    description = "Allow outbound traffic to all port within vpc ipv6"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    ipv6_cidr_blocks = [var.vpc_cidr_v6]
  }
}

resource "aws_security_group" "all_ports_to_self" {
  name  = "${var.name}-all_ports_to_self"
  description = "Allow inbound and outbound from all port to self"
  count =  1 

  vpc_id = var.vpc_id

  ingress {
    description = "Allow inbound traffic from all port from self"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    self        = true
  }

  egress {
    description = "Allow outbound traffic to all port within vpc"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    self = true
  }
}

resource "aws_security_group" "icmp_to_all" {
  name  = "${var.name}-icmp_to_all"
  description = "Allow inbound and outbound from all port using icmp"
  count =  1 

  vpc_id = var.vpc_id

  ingress {
    description = "Allow inbound traffic from all port using icmp"
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr_v4]
  }

  egress {
    description = "Allow outbound traffic to all port within vpc"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.vpc_cidr_v4]
  }

  egress {
    description = "Allow outbound traffic to all port within vpc ipv6"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    ipv6_cidr_blocks = [var.vpc_cidr_v6]
  }
}

resource "aws_security_group" "known_port_to_all" {
  name  = "${var.name}-known_port_to_all"
  description = "Allow inbound and outbound from all known port"
  count =  1 

  vpc_id = var.vpc_id

  ingress {
    description = "Allow inbound traffic from port 22"
    from_port   = 22 # SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_v4]
  }

  ingress {
    description = "Allow inbound traffic from port 25"
    from_port   = 25 # SMTP
    to_port     = 25
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_v4]
  }

  ingress {
    description = "Allow inbound traffic from port 2049"
    from_port   = 2049 # NFS
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_v4]
  }

  ingress {
    description = "Allow inbound traffic from port 3306"
    from_port   = 3306 # mysql
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_v4]
  }

  ingress {
    description = "Allow inbound traffic from port 27017"
    from_port   = 27017 # mongodb
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_v4]
  }

  ingress {
    description = "Allow inbound traffic from port 1433"
    from_port   = 1433 # MsSQL
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_v4]
  }

  ingress {
    description = "Allow inbound traffic from port 1521"
    from_port   = 1521 # Oracle DB
    to_port     = 1521
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_v4]
  }

  ingress {
    description = "Allow inbound traffic from port 5432"
    from_port   = 5432 # PostgreSQL
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_v4]
  }

  ingress {
    description = "Allow inbound traffic from port 3389"
    from_port   = 3389 # RDP
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_v4]
  }

  ingress {
    description = "Allow inbound traffic from port 53"
    from_port   = 53 # DNS
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr_v4]
  }

  egress {
    description = "Allow outbound traffic to all port within vpc ipv4"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.vpc_cidr_v4]
  }

  egress {
    description = "Allow outbound traffic to all port within vpc ipv6"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    ipv6_cidr_blocks = [var.vpc_cidr_v6]
  }
}

resource "aws_security_group" "opens_plaintext_port" {
  name  = "${var.name}-opens_plaintext_port"
  description = "Allow inbound and outbound from plaintext port"
  count =  1 

  vpc_id = var.vpc_id

  ingress {
    description = "Allow inbound traffic from port 21"
    from_port   = 21 # FTP
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_v4]
  }

  ingress {
    description = "Allow inbound traffic from port 23"
    from_port   = 23 # Telnet
    to_port     = 23
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_v4]
  }

  egress {
    description = "Allow outbound traffic to all port within vpc ipv4"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.vpc_cidr_v4]
  }

  egress {
    description = "Allow outbound traffic to all port within vpc ipv6"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    ipv6_cidr_blocks = [var.vpc_cidr_v6]
  }
}

resource "aws_security_group" "opens_port_range" {
  name  = "${var.name}-opens_port_range"
  description = "Allow inbound and outbound from port range"
  count =  1 

  vpc_id = var.vpc_id

  ingress {
    description = "Allow inbound traffic from port 21 to 25"
    from_port   = 21
    to_port     = 25
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_v4]
  }

  egress {
    description = "Allow outbound traffic to all port within vpc ipv4"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.vpc_cidr_v4]
  }

  egress {
    description = "Allow outbound traffic to all port within vpc ipv6"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    ipv6_cidr_blocks = [var.vpc_cidr_v6]
  }
}

resource "aws_security_group" "opens_port_to_all" {
  name  = "${var.name}-opens_port_to_all"
  description = "Allow inbound and outbound from opens port"
  count =  1 

  vpc_id = var.vpc_id

  ingress {
    description = "Allow inbound traffic from port 21 tcp"
    from_port   = 21
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_v4]
  }

  egress {
    description = "Allow outbound traffic to all port within vpc ipv4"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.vpc_cidr_v4]
  }

  egress {
    description = "Allow outbound traffic to all port within vpc ipv6"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    ipv6_cidr_blocks = [var.vpc_cidr_v6]
  }
}

resource "aws_security_group" "whitelists_aws_ip_from_banned_region" {
  name  = "${var.name}-whitelists_aws_ip_from_banned_region"
  description = "Allow inbound and outbound from whitelist aws ip from banned region"
  count =  1 

  vpc_id = var.vpc_id

  ingress {
    description = "Allow inbound traffic from whitelist ip"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["52.28.0.0/32"] # eu-central-1
  }

  egress {
    description = "Allow outbound traffic to all port within vpc ipv4"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.vpc_cidr_v4]
  }

  egress {
    description = "Allow outbound traffic to all port within vpc ipv6"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    ipv6_cidr_blocks = [var.vpc_cidr_v6]
  }
}

resource "aws_security_group" "whitelists_aws" {
  name  = "${var.name}-whitelists_aws"
  description = "Allow inbound and outbound from whitelist ip"
  count =  1 

  vpc_id = var.vpc_id

  ingress {
    description = "Allow inbound traffic from whitelist port"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["52.14.0.0/32"] # us-east-2
  }

  egress {
    description = "Allow outbound traffic to all port within vpc ipv4"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.vpc_cidr_v4]
  }

  egress {
    description = "Allow outbound traffic to all port within vpc ipv6"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    ipv6_cidr_blocks = [var.vpc_cidr_v6]
  }
}

resource "aws_security_group" "whitelists_unknown_cidrs" {
  name  = "${var.name}-whitelists_unknown_cidrs"
  description = "Allow inbound and outbound from whitelist unknown cidr"
  count =  1 

  vpc_id = var.vpc_id

  ingress {
    description = "Allow inbound traffic from unknown cidr"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["8.8.8.8/32"]
  }

  egress {
    description = "Allow outbound traffic to all port within vpc ipv4"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.vpc_cidr_v4]
  }

  egress {
    description = "Allow outbound traffic to all port within vpc ipv6"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    ipv6_cidr_blocks = [var.vpc_cidr_v6]
  }
}

resource "aws_security_group" "unused_security_group" {
  name  = "${var.name}-unused_security_group"
  description = "unused security group"
  count =  1 

  vpc_id = var.vpc_id

  ingress {
    description = "Allow inbound traffic from unknown cidr"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["8.8.8.8/32"]
  }

  egress {
    description = "Allow outbound traffic to all port within vpc ipv4"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.vpc_cidr_v4]
  }

  egress {
    description = "Allow outbound traffic to all port within vpc ipv6"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    ipv6_cidr_blocks = [var.vpc_cidr_v6]
  }
}

/**
#Delete
resource "aws_security_group" "unneeded_security_group" {
  name  = "${var.name}-unneeded_security_group"
  count =  1 

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["127.0.0.0/8"]
  }
}

#Delete
resource "aws_security_group" "unexpected_security_group" {
  name  = "${var.name}-unexpected_security_group"
  count = 1 

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/8"]
  }
}

**/

resource "aws_security_group" "overlapping_security_group" {
  name  = "${var.name}-overlapping_security_group"
  description = "Security group with 2 overlapping rule"
  count =  1 

  vpc_id = var.vpc_id

  ingress {
    description = "Allow inbound traffic from cidr 162.168.2.0/24"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["162.168.2.0/32"]
  }

  /**
  ingress {
    description = "Allow inbound traffic from cidr 162.168.2.0/25"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["162.168.2.0/32"]
  }
  **/
}
