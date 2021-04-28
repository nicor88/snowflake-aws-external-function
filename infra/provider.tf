terraform {
  required_version = ">= 0.14"
  required_providers {
    archive = {
      source = "hashicorp/archive"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}
