terraform {
  required_version = ">=0.12"
}

provider "aws" {
  version = "~> 2.42"
  region  = "ap-northeast-1"
}

#########################
# VPC
#########################
resource "aws_vpc" "this" {
  cidr_block = var.cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = var.tags
}

#########################
# Flow Log
#########################
resource "aws_iam_role" "flowlog" {
  name = "${var.name}-flowlog"

  assume_role_policy = <<EOL
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOL

  tags = var.tags
}

resource "aws_iam_role_policy" "flowlog_policy" {
  role = aws_iam_role.flowlog.id

  name = "${var.name}-flowlog"

  policy = <<EOL
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOL
}

resource "aws_cloudwatch_log_group" "flowlog" {
  name              = "/${var.name}/vpc/flow"
  retention_in_days = 7
}

resource "aws_flow_log" "flowlog" {
  depends_on = [aws_cloudwatch_log_group.flowlog]

  iam_role_arn    = aws_iam_role.flowlog.arn
  log_destination = aws_cloudwatch_log_group.flowlog.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.this.id
}

#########################
# Internet Gateway
#########################
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = var.tags
}

#########################
# Public Route Table
#########################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    map("Name", format("%s-public", var.name))
  )
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

#########################
# Public Subnet
#########################
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id = aws_vpc.this.id

  cidr_block        = element(var.public_subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = merge(
    var.tags,
    map("Name", format("%s-public-%d", var.name, count.index))
  )
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

#########################
# Private Route Table
#########################
resource "aws_route_table" "private" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    map("Name", format("%s-private-%d", var.name, count.index))
  )
}

#########################
# Private Subnet
#########################
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.this.id

  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = merge(
    var.tags,
    map("Name", format("%s-private-%d", var.name, count.index))
  )
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

#########################
# NAT Gateway
#########################
resource "aws_eip" "nat" {
  count = length(var.private_subnets)

  vpc = true

  tags = merge(
    var.tags,
    map("Name", format("%s-%d", var.name, count.index))
  )
}

resource "aws_nat_gateway" "this" {
  count = length(var.private_subnets)

  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = merge(
    var.tags,
    map("Name", format("%s-%d", var.name, count.index))
  )

  depends_on = [aws_eip.nat]
}

resource "aws_route" "private_nat_gateway" {
  count = length(var.private_subnets)

  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this.*.id, count.index)
}

