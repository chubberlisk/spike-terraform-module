provider "aws" {
  region  = "eu-west-2"
}

module "api_gateway" {
  source = "../"

  namespace = "api-gateway-spike"
  http_proxy_uri = "https://wentingwang.co.uk"
  file_to_force_deployment = "main.tf"
  environment = "spike"
  clients = ["steven", "connie", "greg"]
}
