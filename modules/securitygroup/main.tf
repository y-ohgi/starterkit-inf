resource "aws_security_group" "this" {
  vpc_id      = var.vpc_id
  name        = var.name
  description = var.name

  tags = merge(
    var.tags,
    map("Name", var.name)
  )
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
  description = var.name
}

resource "aws_security_group_rule" "ingress_with_security_group" {
  count = length(var.ingress_with_security_group_rules)

  type = "ingress"

  security_group_id = aws_security_group.this.id

  source_security_group_id = lookup(var.ingress_with_security_group_rules[count.index], "source_security_group_id")

  from_port   = lookup(var.ingress_with_security_group_rules[count.index], "port")
  to_port     = lookup(var.ingress_with_security_group_rules[count.index], "port")
  protocol    = "tcp"
  description = var.name
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
