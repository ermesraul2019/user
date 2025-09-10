data "aws_iam_policy_document" "s3_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.avatars.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "lambda_policy_full" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = [
      aws_dynamodb_table.users.arn,
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.avatars.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "producer_policy" {
  statement {
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.create_request_card.arn]
  }
}

data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "AvatarsBucket"
    key    = "infra/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  create_request_card_sqs_url = data.terraform_remote_state.infra.outputs.create_request_card_sqs_url
}
