resource "aws_api_gateway_client_certificate" "main" {
  description = "Client certificate for ${var.namespace}."
}
