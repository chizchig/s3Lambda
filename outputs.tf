output "sns_topic_arn" {
  value = aws_sns_topic.new_s3_alert.arn
}

output "sqs_queue_arn" {
  value = aws_sqs_queue.ds3_sqs.arn
}

output "lambda_function_arn" {
  value = aws_lambda_function.ds3_lambda.arn
}