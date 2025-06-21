resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "task1-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.main.id
  count = length(var.subnet_azs)

  availability_zone = var.subnet_azs[count.index]
  cidr_block        = var.public_subnet_cidr_blocks[count.index]

  tags = {
    Name = "task1-public-subnet-${count.index}"
  }
}

resource "aws_route_table" "task1_rts" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.task1_igw.id
  }
}

resource "aws_route_table_association" "public_rta" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.task1_rts.id
}

resource "aws_db_subnet_group" "task1_db_subnet_group" {
  name       = "task1-db-subnet-group"
  subnet_ids = [for subnet in aws_subnet.public_subnet : subnet.id]

  tags = {
    Name = "task1-db-subnet-group"
  }
}

resource "aws_internet_gateway" "task1_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "task1-igw"
  }
}

