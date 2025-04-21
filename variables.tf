variable "aws_region" {
  default = "eu-west-2"
}

variable "domain_name" {
  description = "Domain name of your website"
}

variable "hosted_zone_id" {
  description = "Id of the hosted zone you have created"
}

//TODO create env var
variable "s3_bucket_utils" {
  default = "self-signed-certs-project-utils"
}
