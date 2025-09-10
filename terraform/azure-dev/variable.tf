variable "location" {
  type        = string
  description = "Azure region, e.g., eastasia, southeastasia, eastus"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "cosmos_account_name" {
  type        = string
  description = "Globally unique Cosmos DB account name"
}

variable "cosmos_database_name" {
  type        = string
  description = "Mongo database name to create"
  default     = "dev"
}

variable "acr_name" {
  type        = string
  description = "Azure Container Registry name"
}

variable "acr_sku" {
  type        = string
  description = "ACR SKU (Basic, Standard, Premium)"
  default     = "Basic"
}

variable "log_analytics_name" {
  type        = string
  description = "Log Analytics Workspace name"
}

variable "containerapps_env_name" {
  type        = string
  description = "Container Apps Environment name"
}

variable "backend_app_name" {
  type        = string
  description = "Container App name for backend"
}

variable "backend_image" {
  type        = string
  description = "Backend container image (e.g., <acr>.azurecr.io/backend:tag)"
}

variable "static_site_account_name" {
  type        = string
  description = "Storage account name for static website"
}

variable "frontdoor_profile_name" {
  type        = string
  description = "Front Door profile name"
}

variable "frontdoor_endpoint_name" {
  type        = string
  description = "Front Door endpoint name"
}

