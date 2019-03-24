resource "aws_acm_certificate" "site_cert" {
  domain_name = "${var.cert_domain}"
  subject_alternative_names = ["*.${var.cert_domain}"]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "zone" {
  name = "${var.zone}"
  private_zone = false
}

resource "aws_route53_record" "cert_validation" {
  zone_id = "${data.aws_route53_zone.zone.id}"
  name = "${lookup(aws_acm_certificate.site_cert.domain_validation_options[0], "resource_record_name")}"
  type = "${lookup(aws_acm_certificate.site_cert.domain_validation_options[0], "resource_record_type")}"
  ttl = 300
  records = ["${lookup(aws_acm_certificate.site_cert.domain_validation_options[0], "resource_record_value")}"]
}

# A Records for v4
resource "aws_route53_record" "wwwv4" {
  count = "${length(var.domains)}"
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name = "${element(var.domains, count.index)}"
  type = "A"
  alias {
    name = "${aws_cloudfront_distribution.site_distribution.domain_name}"
    zone_id = "${aws_cloudfront_distribution.site_distribution.hosted_zone_id}"
    # cannot be true for cloudfront aliases
    evaluate_target_health = false
  }
}

# Quad A records for v6
resource "aws_route53_record" "wwwv6" {
  count = "${length(var.domains)}"
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name = "${element(var.domains, count.index)}"
  type = "AAAA"
  alias {
    name = "${aws_cloudfront_distribution.site_distribution.domain_name}"
    zone_id = "${aws_cloudfront_distribution.site_distribution.hosted_zone_id}"
    # cannot be true for cloudfront aliases
    evaluate_target_health = false
  }
}
