# Terraform Block
terraform {
  required_version = ">= 1.1.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.10.0, < 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.96.0" // do not use with 2.95
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1"
    }
  }
}

# Provider Block
provider "google" {
  // if using a keyfile to authenticate to Google, you can uncomment below
  // and point to your valid file
  // credentials = file("keys/key1.json")
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}
provider "google-beta" {
  // if using a keyfile to authenticate to Google, you can uncomment below
  // and point to your valid file
  // credentials = file("keys/key1.json")
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}
provider "azurerm" {
  features {}

  // If using a Service Principal to authenticate to Azure
  // You can uncomment below and set your specific parameters
  //subscription_id = "00000000-0000-0000-0000-000000000000"
  //client_id       = "00000000-0000-0000-0000-000000000000"
  //client_secret   = "anexamplekeythatdoesntworkanywhere"
  //tenant_id       = "00000000-0000-0000-0000-000000000000"
}

