locals {
  description = "${var.description != "" ? var.description : var.name}"
}

resource "aws_security_group" "this" {
  vpc_id      = var.vpc_id
  name        = var.name
  description = local.description
  tags        = var.tags
}

#########################
# Ingress Rule
#########################
resource "aws_security_group_rule" "ingress" {
  count = length(var.ingress)

  type = "ingress"

  security_group_id = aws_security_group.this.id

  cidr_blocks = split(",", lookup(var.ingress[count.index], "cidr_blocks"))

  from_port   = lookup(var.ingress[count.index], "port")
  to_port     = lookup(var.ingress[count.index], "port")
  protocol    = "tcp"
  description = ""
}

resource "aws_security_group_rule" "ingress_with_cidr_block" {
  count = length(var.ingress_with_cidr_block_rules)

  type = "ingress"

  security_group_id = aws_security_group.this.id

  cidr_blocks = split(",", lookup(var.ingress_with_cidr_block_rules[count.index], "cidr_blocks"))

  from_port   = lookup(var.ingress_with_cidr_block_rules[count.index], "from_port")
  to_port     = lookup(var.ingress_with_cidr_block_rules[count.index], "to_port")
  protocol    = lookup(var.ingress_with_cidr_block_rules[count.index], "protocol")
  description = lookup(var.ingress_with_cidr_block_rules[count.index], "description")
}

#########################
# Egress Rule
#########################
resource "aws_security_group_rule" "egress" {
  type = "egress"

  security_group_id = aws_security_group.this.id

  cidr_blocks = ["0.0.0.0/0"]

  from_port = 0
  to_port   = 0
  protocol  = "-1"
}
