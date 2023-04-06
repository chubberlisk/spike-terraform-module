variable "namespace" {
  description = "The name of the Cloud Platform namespace."
  default = "hmpps-integration-api-development"
}

variable "http_proxy_uri" {
  description = "The URI to forward HTTP requests to."
}

variable "file_to_force_deployment" {
  description = "The path to file to force deployment."
}

