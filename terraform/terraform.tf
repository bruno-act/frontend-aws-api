terraform {
  required_version = "~> 1.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }

    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.48"
    }
  }
  backend "s3" {
    bucket = "act-phi-api-terraform-state-bucket-dev"
    key    = "terraform/state"
    region = "af-south-1"
  }
}

