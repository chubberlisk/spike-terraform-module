output "truststore_s3_bucket_iam_credentials" {
  description = "Credentials to access truststore S3 bucket."
  sensitive   = true

  value = {
    access_key_id     = module.truststore_s3_bucket.access_key_id
    secret_access_key = module.truststore_s3_bucket.secret_access_key
    bucket_arn        = module.truststore_s3_bucket.bucket_arn
    bucket_name       = module.truststore_s3_bucket.bucket_name
  }
}

output "api_keys" {
  description = "API keys for clients."
  sensitive   = true

  value = {
    for client in var.clients : client => aws_api_gateway_api_key.clients[client].value
  }
}

output "client_certificate" {
  description = "PEM encoded client certificate to authenticate API Gateway."
  sensitive   = true

  value = aws_api_gateway_client_certificate.main.pem_encoded_certificate
}
