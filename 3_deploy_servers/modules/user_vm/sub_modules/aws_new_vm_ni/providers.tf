##############################################################################################################
# Providers
##############################################################################################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Access and secret keys to your environment
//variable "access_key" {}
//variable "secret_key" {}
