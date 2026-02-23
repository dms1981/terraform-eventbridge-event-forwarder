terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.30"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  # profile = "spoke" # or assume_role, env vars, etc.
}

provider "aws" {
  alias  = "spoke"
  region = "us-east-1"
  # profile = "hub" # or assume_role, env vars, etc.
}