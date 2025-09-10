terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.110.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

module "cosmos_mongo" {
  source              = "../modules/azure_cosmos_mongo"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  account_name        = var.cosmos_account_name
  database_name       = var.cosmos_database_name
}

output "cosmos_mongo_connection_string" {
  value       = module.cosmos_mongo.mongo_connection_string
  description = "Mongo connection string for Spring Boot (includes TLS)."
}

module "acr" {
  source              = "../modules/azure_acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  name                = var.acr_name
  sku                 = var.acr_sku
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "acr_admin_username" {
  value = module.acr.admin_username
}

module "container_apps" {
  source              = "../modules/azure_container_apps"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  log_analytics_name  = var.log_analytics_name
  environment_name    = var.containerapps_env_name
  backend_name        = var.backend_app_name
  backend_image       = var.backend_image
  mongo_url           = module.cosmos_mongo.mongo_connection_string
}

output "backend_fqdn" {
  value = module.container_apps.backend_url
}

module "static_site" {
  source              = "../modules/azure_static_site"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  account_name        = var.static_site_account_name
}

output "static_site_endpoint" {
  value = module.static_site.static_website_primary_endpoint
}

module "front_door" {
  source              = "../modules/azure_front_door"
  resource_group_name = azurerm_resource_group.rg.name
  profile_name        = var.frontdoor_profile_name
  endpoint_name       = var.frontdoor_endpoint_name
  backend_host        = module.container_apps.backend_url
  static_host         = module.static_site.static_website_hostname
}

output "frontdoor_hostname" {
  value = module.front_door.frontdoor_hostname
}

