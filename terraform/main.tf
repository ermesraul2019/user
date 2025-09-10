provider "aws" {
  region = var.region
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_sqs_queue" "create_request_card" {
  name = "create-request-card-sqs"
}

resource "aws_sqs_queue" "error_create_request_card" {
  name = "error-create-request-card-sqs"
}

resource "aws_iam_policy" "producer_policy" {
  name   = "ProducerSQSPolicy"
  policy = data.aws_iam_policy_document.producer_policy.json
}

resource "aws_iam_role_policy_attachment" "producer_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.producer_policy.arn
}
