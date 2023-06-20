
# create vpc
resource "aws_vpc" "main" {
  count = 1
  cidr_block = "10.0.0.0/16"

  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames = true # need to be enabled in order for publicly accessible RDS instance finding to work
  enable_dns_support = true # need to be enabled in order for publicly accessible RDS instance finding to work

  tags = {
    Name = "${var.name}_vpc"
  }
}

module "cloudwatch_flow_log" {
  source = "../cloudwatch"
}

module "flow_log_role" {
  source = "../iam"
}

resource "aws_flow_log" "flow_log" {
  name            = "flow_log"
  vpc_id          = aws_vpc.flow_log_role.id
  traffic_type    = "ALL"
  log_destination = module.cloudwatch_flow_log.cloudwatch_flow_log_arn
  iam_role_arn    = module.flow_log_role.flow_log_role_arn
}

# grab AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# create subnet
resource "aws_subnet" "main" {
  count = 1
  vpc_id     = aws_vpc.main[0].id
  cidr_block = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  map_public_ip_on_launch = false

  ipv6_cidr_block = cidrsubnet(aws_vpc.main[0].ipv6_cidr_block, 8, 1)
  assign_ipv6_address_on_creation = true

  tags = {
    Name = "${var.name}_subnet"
  }
}

resource "aws_subnet" "secondary" {
  count = 1
  vpc_id     = aws_vpc.main[0].id
  cidr_block = "10.0.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
}

# create internet gateway
resource "aws_internet_gateway" "main" {
  count = 1
  vpc_id = aws_vpc.main[0].id

  tags = {
    Name = "${var.name}_ig"
  }
}

# create route table
resource "aws_route_table" "main" {
  count = 1
  vpc_id = aws_vpc.main[0].id

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
