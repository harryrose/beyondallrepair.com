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
  bucket = "${var.site_bucket}"
  acl = "private"
}

resource "aws_s3_bucket_policy" "site_policy" {
  bucket = "${aws_s3_bucket.site_public.id}"
  policy = "${data.aws_iam_policy_document.s3_policy.json}"
}
