resource "aws_lambda_function" "user_register" {
  filename         = "register.zip"
  function_name    = "register-lambda"
  handler          = "register.handler"
  runtime          = "nodejs22.x"
  role             = aws_iam_role.lambda_exec_role.arn
  source_code_hash = filebase64sha256("register.zip")
  environment {
    variables = {
      USERS_TABLE    = aws_dynamodb_table.users.name
      USER_POOL_ID   = aws_cognito_user_pool.main.id
      USER_CLIENT_ID = aws_cognito_user_pool_client.main.id
      SQS_URL = aws_sqs_queue.create_request_card.id
    }
  }
}

resource "aws_lambda_function" "user_confirm" {
  filename         = "confirm.zip"
  function_name    = "confirm-lambda"
  handler          = "confirm.handler"
  runtime          = "nodejs22.x"
  role             = aws_iam_role.lambda_exec_role.arn
  source_code_hash = filebase64sha256("confirm.zip")
  environment {
    variables = {
      USERS_TABLE    = aws_dynamodb_table.users.name
      USER_POOL_ID   = aws_cognito_user_pool.main.id
      USER_CLIENT_ID = aws_cognito_user_pool_client.main.id
    }
  }
}


