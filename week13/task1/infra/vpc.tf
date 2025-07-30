resource "aws_vpc" "task3_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "task1-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.task3_vpc.id

  tags = {
    Name = "task1-igw"
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr_blocks)

  vpc_id                  = aws_vpc.task3_vpc.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = var.azs[count.index % length(var.azs)]
  map_public_ip_on_launch = true

  tags = {
    Name = "task1-public-${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.task3_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "task1-public-rt"
  }
}


resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr_blocks)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
