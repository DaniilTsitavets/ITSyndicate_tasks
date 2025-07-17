resource "aws_vpc" "k8s_hard_way_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "k8s-hard-way-vpc"
  }
}

resource "aws_subnet" "k8s_hard_way_public_subnet" {
  count = length(var.public_subnet_cidr_blocks)

  vpc_id                  = aws_vpc.k8s_hard_way_vpc.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = var.azs[count.index % length(var.azs)]
  map_public_ip_on_launch = true

  tags = {
    Name = "k8s-hard-way-vpc-public-${count.index}"
  }
}

resource "aws_internet_gateway" "k8s_hard_way_igw" {
  vpc_id = aws_vpc.k8s_hard_way_vpc.id
  tags = {
    Name = "k8s-hard-way-igw"
  }
}

resource "aws_route_table" "k8s_hard_way_public_rt" {
  vpc_id = aws_vpc.k8s_hard_way_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_hard_way_igw.id
  }

  tags = {
    Name = "k8s-hard-way-public_rt"
  }
}

resource "aws_route_table_association" "k8s_hard_way_public_assoc" {
  count          = length(aws_subnet.k8s_hard_way_public_subnet)
  subnet_id      = aws_subnet.k8s_hard_way_public_subnet[count.index].id
  route_table_id = aws_route_table.k8s_hard_way_public_rt.id
}
