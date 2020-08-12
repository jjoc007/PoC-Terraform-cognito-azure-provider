provider "aws" {
  version = "~> 2.0"
  region  = var.aws_region
}

provider "azuread" {
  version = "=0.7.0"
}