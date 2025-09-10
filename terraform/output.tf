output "avatars_bucket_name" {
  value = aws_s3_bucket.avatars.bucket
}

output "users_table_name" {
  value = aws_dynamodb_table.users.name
}

output "lambda_register_name" {
  value = aws_lambda_function.user_register.function_name
}

output "lambda_confirm_name" {
  value = aws_lambda_function.user_confirm.function_name
}

output "create_request_card_sqs_url" {
  value = aws_sqs_queue.create_request_card.id
}
