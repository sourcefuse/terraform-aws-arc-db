terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.1"
    }

    random = {
      version = "~> 3.4.0"
      source  = "hashicorp/random"
    }
  }
}
