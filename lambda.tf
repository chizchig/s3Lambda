
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/function.zip"
}

resource "aws_lambda_function" "ds3_lambda" {
  function_name = var.function_name
  filename      = data.archive_file.lambda_zip.output_path
  role          = aws_iam_role.iam_for_lambda.arn
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout     = 10
  memory_size = 128

}

resource "aws_lambda_event_source_mapping" "sqs_trigger_lambda" {
  event_source_arn = aws_sqs_queue.ds3_sqs.arn
  function_name    = aws_lambda_function.ds3_lambda.arn
  batch_size       = 10
  enabled          = true
}


resource "aws_lambda_alias" "ds3_lambda" {
  name             = "staging"
  description      = "staging alias"
  function_name    = aws_lambda_function.ds3_lambda.arn
  function_version = "$LATEST"
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ds3_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.new_s3_alert.arn
}