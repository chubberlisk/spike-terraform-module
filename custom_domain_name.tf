resource "aws_api_gateway_domain_name" "custom_domain_name" {
  for_each = aws_acm_certificate_validation.custom_domain_name

  domain_name              = aws_acm_certificate.custom_domain_name.domain_name
  regional_certificate_arn = aws_acm_certificate_validation.custom_domain_name[each.key].certificate_arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  mutual_tls_authentication {
    truststore_uri = "s3://${module.truststore_s3_bucket.bucket_name}/${aws_s3_object.truststore.id}"
  }

  depends_on = [aws_acm_certificate_validation.custom_domain_name]
}

resource "aws_acm_certificate" "custom_domain_name" {
  domain_name       = "${var.hostname}.${var.base_domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "custom_domain_name" {
  for_each = aws_route53_record.cert_validations

  certificate_arn         = aws_acm_certificate.custom_domain_name.arn
  validation_record_fqdns = [aws_route53_record.cert_validations[each.key].fqdn]

  timeouts {
    create = "10m"
  }

  depends_on = [aws_route53_record.cert_validations]
}

data "aws_route53_zone" "base_domain" {
  name         = var.base_domain
  private_zone = false
}

resource "aws_route53_record" "cert_validations" {
  for_each = {
    for domain_validation_option in aws_acm_certificate.custom_domain_name.domain_validation_options : domain_validation_option.domain_name => {
      name    = domain_validation_option.resource_record_name
      record  = domain_validation_option.resource_record_value
      type    = domain_validation_option.resource_record_type
      zone_id = data.aws_route53_zone.base_domain.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_route53_record" "data" {
  for_each = aws_api_gateway_domain_name.custom_domain_name

  zone_id = data.aws_route53_zone.base_domain.zone_id
  name    = "${var.hostname}.${data.aws_route53_zone.base_domain.name}"
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.custom_domain_name[each.key].regional_domain_name
    zone_id                = aws_api_gateway_domain_name.custom_domain_name[each.key].regional_zone_id
    evaluate_target_health = false
  }
}
