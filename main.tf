resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "tf-vpc"
  }
}

resource "aws_subnet" "public" {
  count      = length(var.public_sn_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_sn_cidr[count.index]
  map_public_ip_on_launch = var.auto_assign_pub_ip

  tags = {
    Name = format("public-%s", count.index + 1)
  }
}

resource "aws_subnet" "private" {
  count      = length(var.private_sn_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_sn_cidr[count.index]

  tags = {
    Name = format("private-%s", count.index + 1)
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "tf-vpc-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "tf-vpc-public-route-table"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = var.dest_cidr_block_public_route
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "tf-vpc-private-route-table"
  }
}

resource "aws_route" "private" {
  count                  = var.is_one_nat_gw == true ? 1 : length(var.public_sn_cidr)
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = var.dest_cidr_block_private_route
  nat_gateway_id         = aws_nat_gateway.ngw[count.index].id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_sn_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_sn_cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_nat_gateway" "ngw" {
  count         = var.is_one_nat_gw == true ? 1 : length(var.public_sn_cidr)
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "tf-vpc-nat-gw"
  }
}

resource "aws_eip" "nat" {
  vpc = true
}


resource "aws_security_group" "port_22" {
    name = "port_22_ingress_globally_accessible"
    description = "Allow SSH inbound traffic"
    vpc_id      = aws_vpc.main.id


    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "webserver" {
  count         = var.web_instance == true ? 1 : length(var.public_sn_cidr)
  instance_type = var.instance_type
  ami           = var.image_id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.port_22.id]
  subnet_id = aws_subnet.public[count.index].id
  user_data              = data.template_file.user_data.rendered

  tags = {
    Name = "TF_Server_Ubuntu_18.04"
  }
}

data "template_file" "user_data" {
  template = file("install.sh")
}
