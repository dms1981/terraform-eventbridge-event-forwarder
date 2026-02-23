terraform {
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.30"
    }
  }

  provider_meta "aws" {
    user_agent = [
      "github.com/dms1981/terraform-eventbridge-event-forwarder"
    ]
  }
}