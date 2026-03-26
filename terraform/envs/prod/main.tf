provider "aws" {
  region = "us-east-1"
}

locals {
  name = "internal-prod"
}

module "iam" {
  source = "../../../modules/iam"
  name   = local.name
}

module "lambda" {
  source   = "../../../modules/lambda"
  name     = local.name
  role_arn = module.iam.role_arn
  filename = "../../../scripts/build/function.zip"
}

module "api" {
  source            = "../../../modules/api_gateway"
  name              = local.name
  lambda_invoke_arn = module.lambda.invoke_arn
  lambda_name       = module.lambda.function_name
}