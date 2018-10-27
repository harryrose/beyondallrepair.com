output "ci_server_access_key_id" {
  value = "${aws_iam_access_key.ci_user.id}"
}

output "ci_server_secret_key" {
  value = "${aws_iam_access_key.ci_user.secret}"
}

output "cloudfront_hostname" {
  value = "${aws_cloudfront_distribution.site_distribution.domain_name}"
}