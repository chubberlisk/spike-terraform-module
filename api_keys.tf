resource "random_password" "api_keys" {
  count = length(var.clients)

  length  = 16
  special = false
}

resource "aws_api_gateway_api_key" "clients" {
  count = length(var.clients)

  name  = "${var.namespace}-${var.clients[count.index]}-key"
  value = "${var.namespace}-${var.clients[count.index]}-${random_password.api_keys[count.index].result}"
}

resource "aws_api_gateway_usage_plan" "default" {
  name = var.namespace

  api_stages {
    api_id = aws_api_gateway_rest_api.api_gateway.id
    stage  = aws_api_gateway_stage.main.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "clients" {
  for_each = aws_api_gateway_api_key.clients

  key_id        = aws_api_gateway_api_key.clients[each.key].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}
