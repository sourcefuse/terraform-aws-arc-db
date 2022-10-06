terraform {
    required_version = ">= 1.0.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.25.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.1"
    }
    random = {
      version = ">=3.0.0"
      source  = "hashicorp/random"
    }
  }
}
