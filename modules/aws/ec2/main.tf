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
  instance_type = "t2.micro"
  subnet_id     = var.main_subnet_id
  count         = 1

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

module "all_ports_to_all" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "${var.name}-all_ports_to_all"
  description = "Allow inbound and outbound from all port"
  count       = 1
  vpc_id      = var.vpc_id

  ingress_cidr_blocks     = [var.vpc_cidr_v4]
  egress_cidr_blocks      = [var.vpc_cidr_v4]
  egress_ipv6_cidr_blocks = [var.vpc_cidr_v6]

  ingress_rules = ["all-all"]
  egress_rules  = ["all-all"]
}

module "all_ports_to_self" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "${var.name}-all_ports_to_self"
  description = "Allow inbound and outbound from all port to self"
  count       = 1

  vpc_id = var.vpc_id

  ingress_with_self = [
    {
      rule = "all-all"
    }
  ]

  egress_with_self = [
    {
      rule = "all-all"
    }
  ]
}

module "icmp_to_all" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "${var.name}-icmp_to_all"
  description = "Allow inbound and outbound from all port using icmp"
  count       = 1
  vpc_id      = var.vpc_id

  ingress_cidr_blocks     = [var.vpc_cidr_v4]
  egress_cidr_blocks      = [var.vpc_cidr_v4]
  egress_ipv6_cidr_blocks = [var.vpc_cidr_v6]

  ingress_rules = ["all-icmp"]
  egress_rules  = ["all-all"]
}

module "known_port_to_all" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "${var.name}-known_port_to_all"
  description = "Allow inbound and outbound from all known port"
  count       = 1
  vpc_id      = var.vpc_id

  ingress_cidr_blocks     = [var.vpc_cidr_v4]
  egress_cidr_blocks      = [var.vpc_cidr_v4]
  egress_ipv6_cidr_blocks = [var.vpc_cidr_v6]

  ingress_rules = [
    "ssh-tcp", "smtp-tcp", "nfs-tcp",
    "mysql-tcp", "mongodb-27017-tcp", "mssql-tcp",
    "oracle-db-tcp", "postgresql-tcp", "rdp-tcp",
  "dns-udp"]
  egress_rules = ["all-all"]
}

module "opens_plaintext_port" {
  source                  = "terraform-aws-modules/security-group/aws"
  name                    = "${var.name}-opens_plaintext_port"
  description             = "Allow inbound and outbound from plaintext port"
  count                   = 1
  vpc_id                  = var.vpc_id
  egress_cidr_blocks      = [var.vpc_cidr_v4]
  egress_ipv6_cidr_blocks = [var.vpc_cidr_v6]


  ingress_with_cidr_blocks = [
    {
      description = "Allow inbound traffic from port 21"
      from_port   = 21 # FTP
      to_port     = 21
      protocol    = "tcp"
      cidr_blocks = var.vpc_cidr_v4
    },
    {
      description = "Allow inbound traffic from port 23"
      from_port   = 23 # Telnet
      to_port     = 23
      protocol    = "tcp"
      cidr_blocks = var.vpc_cidr_v4
    }
  ]

  egress_rules = ["all-all"]
}

module "opens_port_range" {
  source                  = "terraform-aws-modules/security-group/aws"
  name                    = "${var.name}-opens_port_range"
  description             = "Allow inbound and outbound from port range"
  count                   = 1
  vpc_id                  = var.vpc_id
  egress_cidr_blocks      = [var.vpc_cidr_v4]
  egress_ipv6_cidr_blocks = [var.vpc_cidr_v6]


  ingress_with_cidr_blocks = [
    {
      description = "Allow inbound traffic from port 21 to 25"
      from_port   = 21
      to_port     = 25
      protocol    = "tcp"
      cidr_blocks = var.vpc_cidr_v4
    }
  ]

  egress_rules = ["all-all"]
}

module "opens_port_to_all" {
  source                  = "terraform-aws-modules/security-group/aws"
  name                    = "${var.name}-opens_port_to_all"
  description             = "Allow inbound and outbound from opens port"
  count                   = 1
  vpc_id                  = var.vpc_id
  egress_cidr_blocks      = [var.vpc_cidr_v4]
  egress_ipv6_cidr_blocks = [var.vpc_cidr_v6]


  ingress_with_cidr_blocks = [
    {
      description = "Allow inbound traffic from port 21 tcp"
      from_port   = 21
      to_port     = 21
      protocol    = "tcp"
      cidr_blocks = var.vpc_cidr_v4
    }
  ]

  egress_rules = ["all-all"]
}

module "whitelists_aws_ip_from_banned_region" {
  source                  = "terraform-aws-modules/security-group/aws"
  name                    = "${var.name}-whitelists_aws_ip_from_banned_region"
  description             = "Allow inbound and outbound from whitelist aws ip from banned region"
  count                   = 1
  vpc_id                  = var.vpc_id
  egress_cidr_blocks      = [var.vpc_cidr_v4]
  egress_ipv6_cidr_blocks = [var.vpc_cidr_v6]


  ingress_with_cidr_blocks = [
    {
      description = "Allow inbound traffic from whitelist ip"
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "52.28.0.0/32" # eu-central-1
    }
  ]

  egress_rules = ["all-all"]
}

module "whitelists_aws" {
  source                  = "terraform-aws-modules/security-group/aws"
  name                    = "${var.name}-whitelists_aws"
  description             = "Allow inbound and outbound from whitelist ip"
  count                   = 1
  vpc_id                  = var.vpc_id
  egress_cidr_blocks      = [var.vpc_cidr_v4]
  egress_ipv6_cidr_blocks = [var.vpc_cidr_v6]


  ingress_with_cidr_blocks = [
    {
      description = "Allow inbound traffic from whitelist port"
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "52.14.0.0/32" # us-east-2
    }
  ]

  egress_rules = ["all-all"]
}

module "whitelists_unknown_cidrs" {
  source                  = "terraform-aws-modules/security-group/aws"
  name                    = "${var.name}-whitelists_unknown_cidrs"
  description             = "Allow inbound and outbound from whitelist unknown cidr"
  count                   = 1
  vpc_id                  = var.vpc_id
  egress_cidr_blocks      = [var.vpc_cidr_v4]
  egress_ipv6_cidr_blocks = [var.vpc_cidr_v6]


  ingress_with_cidr_blocks = [
    {
      description = "Allow inbound traffic from unknown cidr"
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "8.8.8.8/32"
    }
  ]

  egress_rules = ["all-all"]
}

module "unused_security_group" {
  source                  = "terraform-aws-modules/security-group/aws"
  name                    = "${var.name}-unused_security_group"
  description             = "unused security group"
  count                   = 1
  vpc_id                  = var.vpc_id
  egress_cidr_blocks      = [var.vpc_cidr_v4]
  egress_ipv6_cidr_blocks = [var.vpc_cidr_v6]


  ingress_with_cidr_blocks = [
    {
      description = "Allow inbound traffic from unknown cidr"
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "8.8.8.8/32"
    }
  ]

  egress_rules = ["all-all"]
}

module "overlapping_security_group" {
  source                  = "terraform-aws-modules/security-group/aws"
  name                    = "${var.name}-overlapping_security_group"
  description             = "Security group with 2 overlapping rule"
  count                   = 1
  vpc_id                  = var.vpc_id
  egress_cidr_blocks      = [var.vpc_cidr_v4]
  egress_ipv6_cidr_blocks = [var.vpc_cidr_v6]


  ingress_with_cidr_blocks = [
    {
      description = "Allow inbound traffic from cidr 162.168.2.0/24"
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "162.168.2.0/32"
    }
  ]

  egress_rules = ["all-all"]
}

