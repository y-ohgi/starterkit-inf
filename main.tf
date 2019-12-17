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

#########################
# VPC
#########################
module "vpc" {
  source = "./modules/vpc"
  name   = local.name
  tags   = local.tags
}

#########################
# Security Group
#########################
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

#########################
# ALB
#########################
module "acm" {
  source = "./modules/acm"

  name = local.name
  tags = local.tags

  domains = split(",", local.workspace["domains"])
}

module "alb" {
  source = "./modules/alb"

  name = local.name
  tags = local.tags

  subnets         = module.vpc.public_subnets
  security_groups = [module.sg_alb.sg_id]
  acm_arn         = module.acm.acm_arn
}

#########################
# Domain
#########################
locals {
  domains = split(",", local.workspace["domains"])
}

data "aws_route53_zone" "this" {
  name         = local.domains[0]
  private_zone = false
}

resource "aws_route53_record" "this" {
  count = length(local.domains)

  name    = local.domains[count.index]
  zone_id = data.aws_route53_zone.this.id

  type = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}

#########################
# ECS Cluster
#########################
resource "aws_ecs_cluster" "this" {
  name = local.name
  tags = local.tags

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
