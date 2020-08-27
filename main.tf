terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.55.0"
  region  = var.region
}

provider "random" {
  version = "~> 2.1"
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}




resource "random_string" "suffix" {
  length  = 8
  special = false
}
