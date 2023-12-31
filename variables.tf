variable "aws_region" {
  default = "eu-west-2"
}

variable "domain_name" {
  description = "Domain name of your website"
}

variable "hosted_zone_id" {
  description = "Id of the hosted zone you have created"
}