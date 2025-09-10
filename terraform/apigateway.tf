resource "aws_api_gateway_rest_api" "user_api" {
  name        = "user-api"
  description = "API for user management"
}

resource "aws_api_gateway_authorizer" "cognito" {
  name            = "cognito-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.user_api.id
  identity_source = "method.request.header.Authorization"
  type            = "COGNITO_USER_POOLS"
  provider_arns   = [aws_cognito_user_pool.main.arn]
}

resource "aws_api_gateway_resource" "register_user" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  parent_id   = aws_api_gateway_rest_api.user_api.root_resource_id
  path_part   = "register"
}

resource "aws_api_gateway_method" "register_user" {
  rest_api_id   = aws_api_gateway_rest_api.user_api.id
  resource_id   = aws_api_gateway_resource.register_user.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "register_user_integration" {
  rest_api_id             = aws_api_gateway_rest_api.user_api.id
  resource_id             = aws_api_gateway_resource.register_user.id
  http_method             = aws_api_gateway_method.register_user.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.user_register.invoke_arn
}

resource "aws_lambda_permission" "allow_api_gateway_register_user" {
  statement_id  = "AllowExecutionFromAPIGatewayRegisterUser"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user_register.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}

resource "aws_api_gateway_resource" "confirm_user" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  parent_id   = aws_api_gateway_rest_api.user_api.root_resource_id
  path_part   = "confirm"
}

resource "aws_api_gateway_method" "confirm_user" {
  rest_api_id   = aws_api_gateway_rest_api.user_api.id
  resource_id   = aws_api_gateway_resource.confirm_user.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "confirm_user_integration" {
  rest_api_id             = aws_api_gateway_rest_api.user_api.id
  resource_id             = aws_api_gateway_resource.confirm_user.id
  http_method             = aws_api_gateway_method.confirm_user.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.user_confirm.invoke_arn
}

resource "aws_lambda_permission" "allow_api_gateway_confirm_user" {
  statement_id  = "AllowExecutionFromAPIGatewayConfirmUser"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user_confirm.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "user_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.register_user_integration,
    aws_api_gateway_integration.confirm_user_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  description = "User API Deployment at ${timestamp()}"
}

resource "aws_api_gateway_stage" "user_api_stage" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.user_api.id
  deployment_id = aws_api_gateway_deployment.user_api_deployment.id
}
