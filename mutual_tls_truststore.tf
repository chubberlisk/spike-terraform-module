module "truststore_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.2"

  application            = var.application
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  business-unit          = var.business_unit
  is-production          = var.is_production

  bucket_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowBucketAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.api_gateway_role.arn}"
      },
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "$${bucket_arn}/*"
      ]
    }
  ]
}
EOF
}

data "github_repository_file" "truststore" {
  repository = var.github_repository_for_truststore
  file       = var.file_path_for_truststore
}

resource "aws_s3_object" "truststore" {
  bucket  = module.truststore_s3_bucket.bucket_name
  key     = var.file_name_for_truststore
  content = data.github_repository_file.truststore.content
}
