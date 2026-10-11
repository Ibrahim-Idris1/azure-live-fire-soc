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

resource "azurerm_virtual_machine_extension" "ama_linux01" {
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.linux01.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
}

resource "azurerm_monitor_data_collection_rule" "linux_syslog" {
  name                = "dcr-linux-syslog"
  location            = azurerm_resource_group.range.location
  resource_group_name = azurerm_resource_group.range.name
  kind                = "Linux"

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.range.id
      name                  = "law-dest"
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["law-dest"]
  }

  data_sources {
    syslog {
      name           = "syslog-all"
      streams        = ["Microsoft-Syslog"]
      facility_names = ["auth", "authpriv", "cron", "daemon", "kern", "syslog", "user"]
      log_levels     = ["Debug", "Info", "Notice", "Warning", "Error", "Critical", "Alert", "Emergency"]
    }
  }
}

resource "azurerm_monitor_data_collection_rule_association" "linux01" {
  name                    = "dcra-linux-01"
  target_resource_id      = azurerm_linux_virtual_machine.linux01.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.linux_syslog.id
  depends_on              = [azurerm_virtual_machine_extension.ama_linux01]
}