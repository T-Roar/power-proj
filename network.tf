# ********************************************************************************************************************************************
#                                       VPC
# ********************************************************************************************************************************************
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "${var.env}_${var.name}"
  }
}

# ********************************************************************************************************************************************
#                                INTERNET GATEWAY
# ********************************************************************************************************************************************

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    name = "${var.env}_igw"
  }
}
# ********************************************************************************************************************************************
#                                     SUBNETS
# ********************************************************************************************************************************************
#                                     PUBLIC
resource "aws_subnet" "external" {
  count = length(slice(data.aws_availability_zones.az.names, 0, 2))

  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, length(slice(data.aws_availability_zones.az.names, 0, 2)) + count.index)
  availability_zone       = slice(data.aws_availability_zones.az.names, 0, 2)[count.index]
  map_public_ip_on_launch = true
  #   outpost_arn = element(aws_subnet.external.*.arn, count.index)
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}_external-{count.index}"
  }
}
#                                     PRIVATE
resource "aws_subnet" "internal" {
  count = length(slice(data.aws_availability_zones.az.names, 0, 2))

  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, length(slice(data.aws_availability_zones.az.names, 0, 3)) + count.index + 2)
  availability_zone       = slice(data.aws_availability_zones.az.names, 0, 2)[count.index]
  map_public_ip_on_launch = false
  #   outpost_arn = element(aws_subnet.internal.*.arn, count.index)
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}_internal-{count.index}"
  }
}
# *********************************************************************************************************************************************
#                                        ROUTE TABLE
# *********************************************************************************************************************************************
resource "aws_route_table" "external" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.env}_external-rt"
  }
}

resource "aws_route_table" "internal" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}_internal-rt"
  }
}
#                             ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "external" {
  count = length(data.aws_availability_zones.az.names)

  subnet_id      = element(aws_subnet.external.*.id, count.index)
  route_table_id = element(aws_route_table.external.*.id, count.index)
}


resource "aws_route_table_association" "internal" {
  count = length(aws_subnet.internal)

  subnet_id      = aws_subnet.internal[count.index].id
  route_table_id = aws_route_table.internal.id
}
# *********************************************************************************************************************************************
#                                               NAT GATEWAY
# *********************************************************************************************************************************************
resource "aws_nat_gateway" "nat" {
  count = length(aws_subnet.external)

  subnet_id     = element(aws_subnet.external.*.id, count.index)
  allocation_id = element(aws_eip.eip.*.id, count.index)

  tags = {
    Name = "${var.env}_nat-${count.index}"
  }
}
# *********************************************************************************************************************************************
#                                                    EIP
# *********************************************************************************************************************************************
resource "aws_eip" "eip" {
  count = length(aws_subnet.external)

  vpc = true

  tags = {
    Name = "${var.env}_nat-eip-${count.index}"
  }
}