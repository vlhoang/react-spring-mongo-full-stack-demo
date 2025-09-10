resource "azurerm_log_analytics_workspace" "law" {
  name                = var.log_analytics_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "env" {
  name                       = var.environment_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
}

resource "azurerm_container_app" "backend" {
  name                         = var.backend_name
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.env.id

  revision_mode = "Single"

  template {
    container {
      name   = "backend"
      image  = var.backend_image
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "MONGO_URL"
        value = var.mongo_url
      }

      probes {
        type = "liveness"
        http_get {
          path = "/api/students"
          port = 8080
        }
        initial_delay_seconds = 10
        period_seconds        = 30
      }
    }

    scale {
      min_replicas = 1
      max_replicas = 2
    }
  }

  ingress {
    external_enabled = true
    target_port      = 8080
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

output "backend_url" {
  value = azurerm_container_app.backend.latest_revision_fqdn
}

