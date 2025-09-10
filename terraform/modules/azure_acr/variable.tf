variable "resource_group_name" {
  type        = string
  description = "Azure resource group name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "name" {
  type        = string
  description = "ACR name (globally unique)"
}

variable "sku" {
  type        = string
  description = "ACR SKU"
  default     = "Basic"
}

