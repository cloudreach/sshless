# =====================================================
# Create a generic VPC
# =====================================================


variable "cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}


variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}


variable "tags" {
  description = "tags"
  default     = {
    Owner = "demo"
  }
}

data "aws_availability_zones" "available" {}

#
# ######
# # VPC
# ######
resource "aws_vpc" "this" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags = "${merge(var.tags, map("Name", format("vpc-%s", var.name)))}"
}
#
# ###################
# # Internet Gateway
# ###################
resource "aws_internet_gateway" "this" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"
  vpc_id = "${aws_vpc.this.id}"
  tags = "${merge(var.tags, map("Name", format("igw-%s", var.name)))}"
}
#
# ################
# # Publiс routes
# ################
resource "aws_route_table" "public" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"
  vpc_id           = "${aws_vpc.this.id}"
  tags = "${merge(var.tags, map("Name", format("%s-public", var.name)))}"
}

resource "aws_route" "public_internet_gateway" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"
}
#
# ################
# # Public subnet
# ################
resource "aws_subnet" "public" {
  count                   = "${length(var.public_subnets)}"
  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "${var.public_subnets[count.index]}"
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index)}"
  map_public_ip_on_launch = "true"
  tags = "${merge(var.tags, map("Name", format("%s-public-%s", var.name, element(data.aws_availability_zones.available.names, count.index))))}"
}

resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnets)}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}
