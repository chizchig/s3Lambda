variable "bucket" {
  type = string
}

variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
  default     = "alphas3-lambda-function-name"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.function_name)) && length(var.function_name) >= 1 && length(var.function_name) <= 140
    error_message = "Function name must be between 1 and 140 characters long and can only contain letters, numbers, hyphens, and underscores."
  }
}

variable "sqs_queue" {
  type = string
}

variable "analytics" {
  type = string
}

variable "topic_name" {
  type = string
}