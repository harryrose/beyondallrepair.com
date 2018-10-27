data "aws_acm_certificate" "site_cert" {
  domain = "${var.cert_domain}"
  most_recent = true
}

data "aws_route53_zone" "zone" {
  name = "${var.zone}"
  private_zone = false
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
