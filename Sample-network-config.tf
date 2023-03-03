 Create Internet Gateway
# Create Subnets
resource "aws_subnet" "pub_subnet_01" {
  vpc_id     = aws_vpc.vpc_01.id
  cidr_block        = format("%s.1.0/24", var.vpc_cidr)
  availability_zone = var.az_01

  tags = {
    Name         = format("%s%s%s%s%s", var.CustomerCode, "sbn", "pb", var.EnvironmentCode, "01")
    resourcetype = "network"
    codeblock    = "codeblock02"
  }

}

resource "aws_subnet" "pub_subnet_02" {
  vpc_id            = aws_vpc.vpc_01.id
  cidr_block        = format("%s.2.0/24", var.vpc_cidr)
  availability_zone = var.az_02

  tags = {
    Name         = format("%s%s%s%s%s", var.CustomerCode, "sbn", "pb", var.EnvironmentCode, "02")
    resourcetype = "network"
    codeblock    = "codeblock02"
  }

}

resource "aws_subnet" "priv_subnet_01" {
  vpc_id            = aws_vpc.vpc_01.id
  cidr_block        = format("%s.3.0/24", var.vpc_cidr)
  availability_zone = var.az_01

  tags = {
    Name         = format("%s%s%s%s%s", var.CustomerCode, "sbn", "pv", var.EnvironmentCode, "01")
    resourcetype = "network"
    codeblock    = "codeblock02r"
  }

}

resource "aws_subnet" "priv_subnet_02" {
  vpc_id            = aws_vpc.vpc_01.id
  cidr_block        = format("%s.4.0/24", var.vpc_cidr)
  availability_zone = var.az_02

  tags = {
    Name         = format("%s%s%s%s%s", var.CustomerCode, "sbn", "pv", var.EnvironmentCode, "02")
    resourcetype = "network"
    codeblock    = "codeblock02"
  }

}

# Create NAT Gateway
resource "aws_eip" "eip_nat_01" {
  depends_on = [data.aws_internet_gateway.igw]
}

resource "aws_eip" "eip_nat_02" {
  depends_on = [data.aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gateway_01" {
  allocation_id = aws_eip.eip_nat_01.id
  subnet_id     = aws_subnet.pub_subnet_01.id

  tags = {
    Name         = format("%s%s%s%s", var.CustomerCode, "ngw", var.EnvironmentCode, "01")
    resourcetype = "network"
    codeblock    = "codeblock02"
  }

  depends_on = [data.aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gateway_02" {
  allocation_id = aws_eip.eip_nat_02.id
  subnet_id     = aws_subnet.pub_subnet_02.id

  tags = {
    Name         = format("%s%s%s%s", var.CustomerCode, "ngw", var.EnvironmentCode, "02")
    resourcetype = "network"
    codeblock    = "codeblock02"
  }

  depends_on = [data.aws_internet_gateway.igw]
}

# Create Route Tables
resource "aws_route_table" "pub_01" {
  vpc_id = aws_vpc.vpc_01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.igw.internet_gateway_id
  }

  tags = {
    Name         = format("%s%s%s%s%s", var.CustomerCode, "rtt", "pb", var.EnvironmentCode, "01")
    resourcetype = "network"
    codeblock    = "codeblock02"
  }
}

resource "aws_route_table_association" "pub_01" {
  subnet_id      = aws_subnet.pub_subnet_01.id
  route_table_id = aws_route_table.pub_01.id
}

resource "aws_route_table_association" "pub_02" {
  subnet_id      = aws_subnet.pub_subnet_02.id
  route_table_id = aws_route_table.pub_01.id
}

resource "aws_route_table" "priv_01" {
  vpc_id = aws_vpc.vpc_01.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_01.id

  }

  tags = {
    Name         = format("%s%s%s%s%s", var.CustomerCode, "rtt", "pv", var.EnvironmentCode, "01")
    resourcetype = "network"
    codeblock    = "codeblock02"
  }
}

resource "aws_route_table" "priv_02" {
  vpc_id = aws_vpc.vpc_01.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_02.id
  }

  tags = {
    Name         = format("%s%s%s%s%s", var.CustomerCode, "rtt", "pv", var.EnvironmentCode, "02")
    resourcetype = "network"
    codeblock    = "codeblock02"
  }
}

resource "aws_route_table_association" "pv_01" {
  subnet_id      = aws_subnet.priv_subnet_01.id
  route_table_id = aws_route_table.priv_01.id
}

resource "aws_route_table_association" "pv_02" {
  subnet_id      = aws_subnet.priv_subnet_02.id
  route_table_id = aws_route_table.priv_01.id
}

resource "aws_route_table_association" "pv_03" {
  subnet_id      = aws_subnet.priv_subnet_03.id
  route_table_id = aws_route_table.priv_01.id
}

resource "aws_route_table_association" "pv_04" {
  subnet_id      = aws_subnet.priv_subnet_04.id
  route_table_id = aws_route_table.priv_01.id
}

# Security Groups
resource "aws_security_group" "web01" {
  name        = format("%s%s%s%s", var.CustomerCode, "scg", var.EnvironmentCode, "web01")
  description = "Web Security Group"
  vpc_id      = aws_vpc.vpc_01.id

  ingress {
    description = "Web Inbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  ingress {
    description = "Web Inbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Web Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name         = format("%s%s%s%s", var.CustomerCode, "scg", var.EnvironmentCode, "web01")
    resourcetype = "security"
    codeblock    = "codeblock02"
  }
}

resource "aws_security_group" "app01" {
  name        = format("%s%s%s%s", var.CustomerCode, "scg", var.EnvironmentCode, "app01")
  description = " Application Security Group"
  vpc_id      = aws_vpc.vpc_01.id

  ingress {
    description     = "Application Inbound"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.web01.id]
    self            = true
  }

  egress {
    description = "Application Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name         = format("%s%s%s%s", var.CustomerCode, "scg", var.EnvironmentCode, "app01")
    resourcetype = "security"
    codeblock    = "codeblock02"
  }
}