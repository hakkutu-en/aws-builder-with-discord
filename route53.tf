resource "aws_route53_zone" "interactions_api_root" {
  name = var.interactions_api_root_dn

  tags = merge(local.common_tags, {
    Name = var.interactions_api_root_dn
  })
}

resource "aws_route53_record" "interactions_api" {
  for_each = {
    for dvo in aws_acm_certificate.interactions_api.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.interactions_api_root.zone_id
}

resource "aws_route53_record" "interactions_api_dn" {
  zone_id = aws_route53_zone.interactions_api_root.zone_id
  name    = var.interactions_api_dn
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.interactions_api.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.interactions_api.cloudfront_zone_id
    evaluate_target_health = true
  }
}
