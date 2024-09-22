resource "aws_s3_bucket" "ds3" {
  bucket = var.bucket

  force_destroy = true

  tags = {
    Name = "data_storage"
  }
}

resource "aws_s3_bucket" "analytics" {
  bucket = var.analytics
}

resource "aws_s3_bucket_analytics_configuration" "name" {
  bucket = aws_s3_bucket.ds3.id
  name   = "EntireBucket"

  storage_class_analysis {
    data_export {
      destination {
        s3_bucket_destination {
          bucket_arn = aws_s3_bucket.analytics.arn
        }
      }
    }
  }
}

resource "aws_s3_bucket_policy" "b_policy" {
  bucket = aws_s3_bucket.ds3.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3Access"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.iam_for_lambda.arn
        }
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetBucketLocation"
        ]
        Resource = [
          aws_s3_bucket.ds3.arn,
          "${aws_s3_bucket.ds3.arn}/*"
        ]
      },
      {
        Sid    = "DenyDeleteObject"
        Effect = "Deny"
        Principal = {
          AWS = aws_iam_role.iam_for_lambda.arn
        }
        Action   = "s3:DeleteObject"
        Resource = "${aws_s3_bucket.ds3.arn}/*"
      }
    ]
  })
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ds3_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.ds3.arn
}


resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.ds3.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.ds3_lambda.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_prefix       = ""
    filter_suffix       = ".log"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}