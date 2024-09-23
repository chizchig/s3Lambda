
resource "aws_sqs_queue" "ds3_sqs" {
  name    = var.sqs_queue
  
}

resource "aws_sqs_queue_policy" "ds3_sqs_policy" {
  queue_url = aws_sqs_queue.ds3_sqs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.ds3_sqs.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.new_s3_alert.arn
          }
        }
      }
    ]
  })
}