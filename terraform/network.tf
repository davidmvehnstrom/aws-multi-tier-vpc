module "subnets" {
  source = "./modules/subnet-tier"

  vpc_id = aws_vpc.mvc.id

  subnets = {
    pub_a      = { cidr = "10.0.1.0/24", az = "us-east-2a", pub_ip = true, name = "mvc-subnet-pub-a" }
    pub_b      = { cidr = "10.0.2.0/24", az = "us-east-2b", pub_ip = true, name = "mvc-subnet-pub-b" }
    priv_app_a = { cidr = "10.0.3.0/24", az = "us-east-2a", pub_ip = false, name = "mvc-subnet-priv-app-a" }
    priv_app_b = { cidr = "10.0.4.0/24", az = "us-east-2b", pub_ip = false, name = "mvc-subnet-priv-app-b" }
    priv_db_a  = { cidr = "10.0.5.0/24", az = "us-east-2a", pub_ip = false, name = "mvc-subnet-priv-db-a" }
    priv_db_b  = { cidr = "10.0.6.0/24", az = "us-east-2b", pub_ip = false, name = "mvc-subnet-priv-db-b" }
  }
}

resource "aws_internet_gateway" "mvc" {
  vpc_id = aws_vpc.mvc.id
  tags = {
    Name = "mvc-igw"
  }
}

resource "aws_eip" "mvc_nat" {
  domain = "vpc"
  tags = {
    Name = "mvc-eip"
  }
}

resource "aws_nat_gateway" "mvc" {
  subnet_id     = module.subnets.subnet_ids["pub_a"]
  allocation_id = aws_eip.mvc_nat.id
  tags = {
    Name = "mvcnat-gw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.mvc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mvc.id
  }
  tags = {
    Name = "mvc-rt-public"
  }
}

resource "aws_route_table" "priv_app_rt" {
  vpc_id = aws_vpc.mvc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.mvc.id
  }
  tags = {
    Name = "mvc-rt-priv-app"
  }
}

resource "aws_route_table" "priv_db_rt" {
  vpc_id = aws_vpc.mvc.id

  tags = {
    Name = "mvc-rt-priv-db"
  }
}
