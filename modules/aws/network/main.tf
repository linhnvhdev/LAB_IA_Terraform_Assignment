
# create vpc
module "aws_vpc_main" {
  source = "terraform-aws-modules/vpc/aws"
  count = 1
  cidr = "10.0.0.0/16"

  enable_ipv6 = true
  enable_dns_hostnames = true # need to be enabled in order for publicly accessible RDS instance finding to work
  enable_dns_support = true # need to be enabled in order for publicly accessible RDS instance finding to work
  
}

resource "aws_cloudwatch_log_group" "flow_log_group" {
  name = "/aws/vpc-flow-logs"
  kms_key_id = var.kms_key_id
}

resource "aws_iam_role" "flow_log_role_hello" {
  name               = "flow_log_role_hello"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_flow_log" "flow_log" {
  vpc_id          = module.aws_vpc_main[0].vpc_id
  traffic_type    = "ALL"
  log_destination = aws_cloudwatch_log_group.flow_log_group.arn
  iam_role_arn    = aws_iam_role.flow_log_role_hello.arn
}

# grab AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# create subnet
resource "aws_subnet" "main" {
  count = 1
  vpc_id     = module.aws_vpc_main[0].vpc_id
  cidr_block = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  map_public_ip_on_launch = false
  ipv6_cidr_block = cidrsubnet(module.aws_vpc_main[0].vpc_ipv6_cidr_block, 8, 1)
  assign_ipv6_address_on_creation = true

  tags = {
    Name = "${var.name}_subnet"
  }
}

resource "aws_subnet" "secondary" {
  count = 1
  vpc_id     = module.aws_vpc_main[0].vpc_id
  cidr_block = "10.0.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
}

# create internet gateway
resource "aws_internet_gateway" "main" {
  count = 1
  vpc_id = module.aws_vpc_main[0].vpc_id

  tags = {
    Name = "${var.name}_ig"
  }
}

# create route table
resource "aws_route_table" "main" {
  count = 1
  vpc_id = module.aws_vpc_main[0].vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  route {
      ipv6_cidr_block = "::/0"
      gateway_id = aws_internet_gateway.main[0].id
  }

  tags = {
    Name = "${var.name}_routes"
  }
}

# associate route table with subnet
resource "aws_route_table_association" "main" {
  count = 1
  subnet_id      = aws_subnet.main[0].id
  route_table_id = aws_route_table.main[0].id
}
