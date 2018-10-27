# Needed in order to allow cloudfront to access s3
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
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
  name = "${var.name_prefix}lambda_at_edge"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_at_edge_policy.json}"
}


resource "aws_lambda_function" "site_index_lambda" {
  function_name = "${var.name_prefix}index"
  role = "${aws_iam_role.lambda_at_edge_role.arn}"
  source_code_hash = "${base64sha256(file("build/index.zip"))}"
  filename = "build/index.zip"
  publish = true
  handler = "index.handler"
  runtime = "nodejs8.10"
}


resource "aws_cloudfront_distribution" "site_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.site_public.bucket_regional_domain_name}"
    origin_id = "${var.name_prefix}origin"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"

  aliases = ["${var.domains}"]

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods = ["GET","HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id = "${var.name_prefix}origin"
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
