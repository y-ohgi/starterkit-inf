terraform {
  required_version = ">=0.12"
}

provider "aws" {
  version = "~> 2.42"
  region = "ap-northeast-1"
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = var.tags
}


