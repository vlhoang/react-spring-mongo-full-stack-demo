resource "azurerm_storage_account" "sa" {
  name                     = var.account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  static_website {
    index_document     = "index.html"
    error_404_document = "index.html"
  }
}

output "static_website_primary_endpoint" {
  value = azurerm_storage_account.sa.primary_web_endpoint
}

output "static_website_hostname" {
  value = trimprefix(azurerm_storage_account.sa.primary_web_endpoint, "https://")
}

