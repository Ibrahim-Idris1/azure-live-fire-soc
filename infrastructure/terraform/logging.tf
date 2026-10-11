resource "azurerm_log_analytics_workspace" "range" {
  name                = "law-${var.prefix}"
  location            = azurerm_resource_group.range.location
  resource_group_name = azurerm_resource_group.range.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  daily_quota_gb      = 5
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "range" {
  workspace_id = azurerm_log_analytics_workspace.range.id
}