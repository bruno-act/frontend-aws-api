resource "aws_vpc" "phi_api" {
 cidr_block           = "10.0.0.0/16"
 enable_dns_hostnames = true
 enable_dns_support   = true
 
  tags = {
    Name = "${local.naming_prefix}-vpc"
  }
}

resource "aws_subnet" "public_web_subnet_cidrs" {
 count      = length(var.public_web_subnet_cidrs)
 vpc_id     = aws_vpc.phi_api.id
 cidr_block = element(var.public_web_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name           = "${local.naming_prefix}-web-${count.index + 1}"
   IngressEnabled = true
   EgressEnabled  = true
 }
}
 
resource "aws_subnet" "private_app_subnet_cidrs" {
 count      = length(var.private_app_subnet_cidrs)
 vpc_id     = aws_vpc.phi_api.id
 cidr_block = element(var.private_app_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)

 tags = {
   Name           = "${local.naming_prefix}-app-${count.index + 1}"
   IngressEnabled = false
   EgressEnabled  = true
 }
}

resource "aws_subnet" "private_data_subnet_cidrs" {
 count      = length(var.private_data_subnet_cidrs)
 vpc_id     = aws_vpc.phi_api.id
 cidr_block = element(var.private_data_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name           = "${local.naming_prefix}-data-${count.index + 1}"
   IngressEnabled = false
   EgressEnabled  = false
 }
}

resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.phi_api.id
 
 tags = {
   Name = "${local.naming_prefix}-igw"
 }
}

resource "aws_route_table" "secondary" {
 vpc_id = aws_vpc.phi_api.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gw.id
 }
 
 tags = {
   Name = "${local.naming_prefix}-secondary-rtb"
 }
}

resource "aws_route_table_association" "public_subnet_asso" {
 count = length(var.public_web_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_web_subnet_cidrs[*].id, count.index)
 route_table_id = aws_route_table.secondary.id
}