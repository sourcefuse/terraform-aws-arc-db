terraform {
  required_version = ">= 1.0.8"
  required_providers {
    null = {
      version = "3.1.0"
      source  = "hashicorp/null"
    }

    random = {
      version = ">=3.0.0"
      source  = "hashicorp/random"
    }

    aws = {
      version = ">=4.0.0"
      source  = "hashicorp/aws"
    }
  }
}
