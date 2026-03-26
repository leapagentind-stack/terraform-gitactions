resource "aws_lambda_function" "this" {
  function_name = "${var.name}-lambda"
  role          = var.role_arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"

  filename         = var.filename
  source_code_hash = filebase64sha256(var.filename)
}