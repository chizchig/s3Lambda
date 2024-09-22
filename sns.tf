
resource "aws_sns_topic" "new_s3_alert" {
  name                        = var.topic_name
  
}

resource "aws_sns_topic_subscription" "new_lambda_sub" {
  topic_arn = aws_sns_topic.new_s3_alert.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.ds3_lambda.arn
}
