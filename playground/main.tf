terraform {
  backend "local" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"

  default_tags {
    tags = {
      user = "Ting"
    }
  }
}

locals {
  namespace = "hmpps-integration-api-ting"
  environment = "ting"
  clients = ["mapps", "steven", "pearl", "garnet"]
}

module "environment" {
  source = "../"

  namespace = local.namespace
  environment = local.environment
  http_proxy_uri = "https://wentingwang.co.uk"
  file_to_force_deployment = "main.tf"
  clients = local.clients
  application = ""
  business_unit = ""
  file_path_for_truststore = ""
  github_repository_for_truststore = ""
  infrastructure_support = ""
  team_name = ""
}
