# terraform.tf
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
  backend "http" {
    address = var.http_backend
    update_method = "PUT"
  }
}
