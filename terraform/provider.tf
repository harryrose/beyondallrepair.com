provider "aws" {
    region  = "us-east-1"
    profile = "default"
}

# Needed in order to allow cloudfront to access s3
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
}


data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site_public.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.site_public.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket" "site_public" {
    bucket = "beyondallrepair.com"
    acl = "private"
}

resource "aws_s3_bucket_policy" "site_policy" {
  bucket = "${aws_s3_bucket.site_public.id}"
  policy = "${data.aws_iam_policy_document.s3_policy.json}"
}

data "aws_iam_policy_document" "cd_policy_document" {
    statement {
        actions = ["s3:*"]
        resources = ["${aws_s3_bucket.site_public.arn}","${aws_s3_bucket.site_public.arn}/*"]
        effect = "Allow"
    }
}

resource "aws_iam_user_policy" "cd_policy" {
    user = "${aws_iam_user.ci_user.name}"
    policy = "${data.aws_iam_policy_document.cd_policy_document.json}"
}

resource "aws_iam_user" "ci_user" {
    name = "beyondallrepair.com.ci"
}

resource "aws_iam_access_key" "ci_user" {
    user = "${aws_iam_user.ci_user.name}"
}

data "aws_acm_certificate" "site_cert" {
    domain = "*.beyondallrepair.com"
    most_recent = true
}

data "aws_route53_zone" "site_zone" {
    name = "beyondallrepair.com"
}

data "aws_iam_policy_document" "lambda_at_edge_policy" {
    statement {
        actions = [
            "sts:AssumeRole"
        ]

        principals {
            type = "Service"
            identifiers = ["lambda.amazonaws.com"]
        }

        effect = "Allow"
    }
    statement {
            actions = [
                "sts:AssumeRole"
            ]

            principals {
                type = "Service"
                identifiers = ["edgelambda.amazonaws.com"]
            }

            effect = "Allow"
        }
}


resource "aws_iam_role" "lambda_at_edge_role" {
    name = "beyondallrepair.com_lambda_at_edge"
    assume_role_policy = "${data.aws_iam_policy_document.lambda_at_edge_policy.json}"
}


resource "aws_lambda_function" "site_index_lambda" {
    function_name = "beyondallrepair_com_index"
    role = "${aws_iam_role.lambda_at_edge_role.arn}"
    source_code_hash = "${base64sha256(file("build/index.zip"))}"
    filename = "build/index.zip"
    publish = true
    handler = "index.handler"
    runtime = "nodejs8.10"
}

data "aws_route53_zone" "beyondallrepair" {
    name = "beyondallrepair.com"
    private_zone = false
}

resource "aws_route53_record" "www" {
    zone_id = "${data.aws_route53_zone.beyondallrepair.zone_id}"
    name = "www.${data.aws_route53_zone.beyondallrepair.name}"
    type = "CNAME"
    records = ["${aws_cloudfront_distribution.site_distribution.domain_name}"]
    ttl  = 300
}

resource "aws_cloudfront_distribution" "site_distribution" {
    origin {
        domain_name = "${aws_s3_bucket.site_public.bucket_regional_domain_name}"
        origin_id = "beyondallrepair.com_origin"

        s3_origin_config {
            origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
        }
    }

    enabled = true
    is_ipv6_enabled = true
    default_root_object = "index.html"

    aliases = ["beyondallrepair.com", "www.beyondallrepair.com"]

    default_cache_behavior {
        allowed_methods = ["GET", "HEAD", "OPTIONS"]
        cached_methods = ["GET","HEAD"]
        viewer_protocol_policy = "redirect-to-https"
        target_origin_id = "beyondallrepair.com_origin"
        forwarded_values {
            query_string = false

            cookies {
                forward = "none"
            }
        }

        lambda_function_association {
            event_type = "viewer-request"
            lambda_arn = "${aws_lambda_function.site_index_lambda.qualified_arn}"
            include_body = false
        }
    }

    viewer_certificate {
        acm_certificate_arn = "${data.aws_acm_certificate.site_cert.arn}"
        ssl_support_method = "sni-only"
        minimum_protocol_version = "TLSv1"
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }
}

terraform {
    backend "s3" {
        bucket = "beyondallrepair.com.terraform"
        key = "tfstate"
        region = "eu-west-2"
        encrypt = true
        dynamodb_table = "terraform-lock"
        profile = "default"
    }
}

output "ci_server_access_key_id" {
    value = "${aws_iam_access_key.ci_user.id}"
}

output "ci_server_secret_key" {
    value = "${aws_iam_access_key.ci_user.secret}"
}

output "cloudfront_hostname" {
    value = "${aws_cloudfront_distribution.site_distribution.domain_name}"
}