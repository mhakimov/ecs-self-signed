terraform {
  backend "s3" {
    bucket = "ecs-self-signed-remote-state"
    key    = "tests/terraform.tfstate"
    region = "eu-west-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.13.1"
    }
  }
  required_version = ">=0.14.9"
}

provider "aws" {
  region = var.aws_region
}

provider "tfe" {
  hostname = "app.terraform.io"
  token    = var.tfe_token
}
