locals {
  subject_alternative_names = "${slice(var.domains, 1, length(var.domains))}"
}

#########################
# AWS Certificate Manager
#########################
data "aws_route53_zone" "zone" {
  name = var.domains[0]

  private_zone = false
}

resource "aws_acm_certificate" "cert" {
  domain_name               = var.domains[0]
  subject_alternative_names = local.subject_alternative_names

  tags = var.tags

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  depends_on = [aws_acm_certificate.cert]

  count = length(var.domains)

  zone_id = data.aws_route53_zone.zone.id
  name    = lookup(aws_acm_certificate.cert.domain_validation_options[count.index], "resource_record_name")
  type    = lookup(aws_acm_certificate.cert.domain_validation_options[count.index], "resource_record_type")
  records = [lookup(aws_acm_certificate.cert.domain_validation_options[count.index], "resource_record_value")]
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = aws_route53_record.validation.*.fqdn
}
