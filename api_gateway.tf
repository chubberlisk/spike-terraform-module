resource "aws_api_gateway_rest_api" "api_gateway" {
  name                         = var.namespace
  disable_execute_api_endpoint = true

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id      = aws_api_gateway_rest_api.api_gateway.id
  resource_id      = aws_api_gateway_resource.proxy.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "proxy_http_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "${var.http_proxy_uri}/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id

  # Force recreate of the deployment resource
  stage_description = md5(file(var.file_to_force_deployment))

  depends_on = [
    aws_api_gateway_method.proxy,
    aws_api_gateway_integration.proxy_http_proxy
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = var.environment
}

resource "random_id" "api_keys" {
  count       = length(var.clients)
  byte_length = 16
}

resource "aws_api_gateway_api_key" "api_keys" {
  count = length(var.clients)
  name  = "${var.namespace}-${var.clients[count.index]}-key"
  value = "${var.namespace}-${var.clients[count.index]}-${random_id.api_keys[count.index].hex}"
}

resource "aws_api_gateway_usage_plan" "main" {
  name = "${var.namespace}-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.api_gateway.id
    stage  = aws_api_gateway_stage.main.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "main" {
  count = length(var.clients)

  key_id        = aws_api_gateway_api_key.api_keys[count.index].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.main.id
}

