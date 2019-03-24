# Terraform can't use interpolations in the backend configuration,
# so cannot use variables here.
terraform {
  backend "s3" {
    bucket = "beyondallrepair.com.tf"
    key = "site"
    region = "eu-west-2"
    encrypt = true
    dynamodb_table = "terraform-lock"
    profile = "bar"
  }
}

