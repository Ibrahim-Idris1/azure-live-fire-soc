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
      facility_names = ["auth", "authpriv", "cron", "daemon", "kern", "syslog", "user", "local6"]
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

resource "azurerm_virtual_machine_extension" "ama_win01" {
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.win01.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
}

resource "azurerm_monitor_data_collection_rule" "windows_events" {
  name                = "dcr-windows-events"
  location            = azurerm_resource_group.range.location
  resource_group_name = azurerm_resource_group.range.name
  kind                = "Windows"

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.range.id
      name                  = "law-dest"
    }
  }

  data_flow {
    streams      = ["Microsoft-SecurityEvent"]
    destinations = ["law-dest"]
  }

  data_flow {
    streams      = ["Microsoft-Event"]
    destinations = ["law-dest"]
  }

  data_sources {
    # Security events go to the SecurityEvent table (parsed columns, easier KQL)
    windows_event_log {
      name    = "security-events"
      streams = ["Microsoft-SecurityEvent"]
      x_path_queries = [
        "Security!*[System[(EventID=4624 or EventID=4625 or EventID=4648 or EventID=4672 or EventID=4688 or EventID=4697 or EventID=4698 or EventID=4702 or EventID=4719 or EventID=4720 or EventID=4722 or EventID=4724 or EventID=4728 or EventID=4732 or EventID=4738 or EventID=4756 or EventID=4768 or EventID=4769 or EventID=4776 or EventID=1102)]]"
      ]
    }

    # Everything else goes to the Event table
    windows_event_log {
      name    = "sysmon-powershell-defender"
      streams = ["Microsoft-Event"]
      x_path_queries = [
        "Microsoft-Windows-Sysmon/Operational!*",
        "Microsoft-Windows-PowerShell/Operational!*[System[(EventID=4103 or EventID=4104)]]",
        "System!*[System[(EventID=7045)]]",
        "Microsoft-Windows-Windows Defender/Operational!*[System[(EventID=1116 or EventID=1117 or EventID=5001)]]"
      ]
    }
  }
}

resource "azurerm_monitor_data_collection_rule_association" "win01" {
  name                    = "dcra-win-01"
  target_resource_id      = azurerm_windows_virtual_machine.win01.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.windows_events.id
  depends_on              = [azurerm_virtual_machine_extension.ama_win01]
}