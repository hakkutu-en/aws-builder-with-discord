resource "aws_acm_certificate" "interactions_api" {
  domain_name       = var.interactions_api_dn
  validation_method = "DNS"
  provider          = aws.acm

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = var.interactions_api_dn
  })
}

resource "aws_acm_certificate_validation" "interactions_api" {
  certificate_arn         = aws_acm_certificate.interactions_api.arn
  validation_record_fqdns = [for record in aws_route53_record.interactions_api : record.fqdn]
  provider                = aws.acm
}
