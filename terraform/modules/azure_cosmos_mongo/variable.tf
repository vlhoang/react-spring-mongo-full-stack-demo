variable "resource_group_name" {
  type        = string
  description = "Azure resource group name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "account_name" {
  type        = string
  description = "Cosmos DB account name"
}

variable "database_name" {
  type        = string
  description = "Mongo database name"
}

