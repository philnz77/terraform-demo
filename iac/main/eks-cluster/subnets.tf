resource "aws_subnet" "private-zone-a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/19"
  availability_zone = local.zoneA
}

resource "aws_subnet" "private-zone-b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.32.0/19"
  availability_zone = local.zoneB
}

resource "aws_subnet" "public-zone-a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.64.0/19"
  availability_zone       = local.zoneA
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public-zone-b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.96.0/19"
  availability_zone       = local.zoneB
  map_public_ip_on_launch = true
}
