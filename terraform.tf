# terraform.tf
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
  backend "http" {
    address = "https://ax9ulu6oarvy.objectstorage.eu-paris-1.oci.customer-oci.com/p/2meTrUHGj0_rsZgxyPa9WlZatUWbMmuEGP6YN5gfU2n-wjq_p-vWqvUQBMYFTI0c/n/ax9ulu6oarvy/b/afk_bucket/o/terraform.tfstate"
    update_method = "PUT"
  }
}
