##############################################################################################################
# Terraform Providers
##############################################################################################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = local.r1_region["id"]
}

provider "aws" {
  alias      = "r2"
  access_key = var.access_key
  secret_key = var.secret_key
  region     = local.r2_region["id"]
}

provider "aws" {
  alias      = "r3"
  access_key = var.access_key
  secret_key = var.secret_key
  region     = local.r3_region["id"]
}

provider "aws" {
  alias      = "r4"
  access_key = var.access_key
  secret_key = var.secret_key
  region     = local.hub_region["id"]
}

# Access and secret keys to your environment
variable "access_key" {}
variable "secret_key" {}
