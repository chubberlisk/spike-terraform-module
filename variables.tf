# For tags
variable "application" {
  type        = string
  description = "Name of Application you are deploying."
}

variable "namespace" {
  type        = string
  description = "The name of the Cloud Platform namespace."
}

variable "team_name" {
  type        = string
  description = "The name of your development team."
}

variable "environment" {
  type        = string
  description = "The type of environment you're deploying to."
}

variable "infrastructure_support" {
  type        = string
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
}

variable "business_unit" {
  type        = string
  description = "Area of the MOJ responsible for the service."
}

variable "is_production" {
  type    = bool
  default = "true"
}

# For API Gateway
variable "http_proxy_uri" {
  type        = string
  description = "The URI to forward HTTP requests to."
}

variable "file_to_force_deployment" {
  type        = string
  description = "The path to file to force deployment."
}

variable "clients" {
  type        = list(string)
  description = "A list of clients to create API keys for."

  validation {
    condition     = can([for client in var.clients : regex("^[a-z0-9-]+", client)])
    error_message = "Client name must only include alphanumeric characters and hyphens."
  }
}

variable "base_domain" {
  type        = string
  description = "words e.g. hmpps.service.justice.gov.uk"
  default     = "hmpps.service.justice.gov.uk"
}

variable "hostname" {
  type        = string
  description = "Host part of the FQDN"
  default     = "pre-production.integration-api"
}

# For S3 truststore
variable "github_repository_for_truststore" {
  type        = string
  description = "The GitHub repository that stores the truststore file for mutual TLS authentication."
}

variable "file_path_for_truststore" {
  type        = string
  description = "The path to the truststore file in the GitHub repository for mutual TLS authentication."
}

variable "file_name_for_truststore" {
  type        = string
  description = "The file name of the truststore file in the GitHub repository for mutual TLS authentication."
  default     = "truststore.pem"
}
