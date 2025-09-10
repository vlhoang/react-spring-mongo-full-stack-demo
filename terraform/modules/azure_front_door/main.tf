resource "azurerm_cdn_frontdoor_profile" "fdp" {
  name                = var.profile_name
  resource_group_name = var.resource_group_name
  sku_name            = "Standard_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_endpoint" "fde" {
  name                     = var.endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fdp.id
}

resource "azurerm_cdn_frontdoor_origin_group" "backend_group" {
  name                     = "backend-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fdp.id
  session_affinity_enabled = false
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 10
}

resource "azurerm_cdn_frontdoor_origin" "backend_origin" {
  name                           = "backend-origin"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.backend_group.id
  enabled                        = true
  host_name                      = var.backend_host
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = var.backend_host
  priority                       = 1
  weight                         = 1
}

resource "azurerm_cdn_frontdoor_origin_group" "static_group" {
  name                     = "static-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fdp.id
}

resource "azurerm_cdn_frontdoor_origin" "static_origin" {
  name                           = "static-origin"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.static_group.id
  enabled                        = true
  host_name                      = var.static_host
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = var.static_host
}

resource "azurerm_cdn_frontdoor_route" "api_route" {
  name                          = "api-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fde.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.backend_group.id
  patterns_to_match             = ["/api/*"]
  forwarding_protocol           = "MatchRequest"
  https_redirect_enabled        = true
  supported_protocols           = ["Http", "Https"]
}

resource "azurerm_cdn_frontdoor_route" "static_route" {
  name                          = "static-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fde.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.static_group.id
  patterns_to_match             = ["/*"]
  forwarding_protocol           = "MatchRequest"
  https_redirect_enabled        = true
  supported_protocols           = ["Http", "Https"]
}

output "frontdoor_hostname" {
  value = azurerm_cdn_frontdoor_endpoint.fde.host_name
}

