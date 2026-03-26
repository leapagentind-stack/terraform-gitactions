terraform {
  backend "s3" {
    bucket = "tfstate-somu"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}