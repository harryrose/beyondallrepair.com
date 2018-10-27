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
  name = "${var.name_prefix}ci"
}

resource "aws_iam_access_key" "ci_user" {
  user = "${aws_iam_user.ci_user.name}"
}