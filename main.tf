terraform {
  required_version = ">=0.12"
  backend "s3" {
    key    = "starterkit-inf"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  version = "~> 2.42"
  region  = "ap-northeast-1"
}

module "vpc" {
  source = "./modules/vpc"
  name   = local.name
  tags   = local.tags
}

module "sg_alb" {
  source = "./modules/securitygroup"

  vpc_id = module.vpc.vpc_id

  name = "${local.name}-alb"
  tags = local.tags

  ingress = [
    {
      "cidr_blocks" : "0.0.0.0/0",
      "port" : "80"
    },
    {
      "cidr_blocks" : "0.0.0.0/0",
      "port" : "443"
    }
  ]
}

