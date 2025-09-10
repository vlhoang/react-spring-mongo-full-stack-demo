resource "random_password" "cosmos_password" {
  length  = 16
  special = false
}

resource "azurerm_cosmosdb_account" "cosmos" {
  name                = var.account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "MongoDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  capabilities {
    name = "EnableMongo"
  }

  backup {
    type                = "Periodic"
    interval_in_minutes = 60
    retention_in_hours  = 24
  }
}

resource "azurerm_cosmosdb_mongo_database" "db" {
  name                = var.database_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  throughput          = 400
}

# Create a database user by creating a Role Definition + Role Assignment for built-in readWriteAnyDatabase
# Note: For simplicity we will return a connection string using the primary key instead of user credentials.

output "mongo_connection_string" {
  value       = "${azurerm_cosmosdb_account.cosmos.connection_strings[0]}/${var.database_name}"
  description = "Cosmos Mongo connection string including DB name and TLS params."
}

