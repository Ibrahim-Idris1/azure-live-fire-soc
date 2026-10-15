resource "azurerm_automation_account" "range" {
  name                = "aa-livefire-soc"
  location            = azurerm_resource_group.range.location
  resource_group_name = azurerm_resource_group.range.name
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "automation_vm_contributor" {
  scope                = azurerm_resource_group.range.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_automation_account.range.identity[0].principal_id
}

resource "azurerm_automation_runbook" "start_vms" {
  name                    = "Start-LiveFireVMs"
  location                = azurerm_resource_group.range.location
  resource_group_name     = azurerm_resource_group.range.name
  automation_account_name = azurerm_automation_account.range.name
  log_verbose             = true
  log_progress            = true
  runbook_type            = "PowerShell"

  content = <<-PS1
    $ErrorActionPreference = "Stop"
    Connect-AzAccount -Identity | Out-Null

    $rg = "rg-livefire-soc"
    $vms = @("vm-win-01", "vm-linux-01")

    foreach ($vm in $vms) {
      Write-Output "Starting $vm..."
      Start-AzVM -ResourceGroupName $rg -Name $vm -NoWait
    }
  PS1
}

resource "azurerm_automation_schedule" "morning_start" {
  name                    = "daily-8am-start"
  resource_group_name     = azurerm_resource_group.range.name
  automation_account_name = azurerm_automation_account.range.name
  frequency               = "Day"
  interval                = 1
  timezone                = "Africa/Lagos"
  start_time              = "${formatdate("YYYY-MM-DD", timeadd(timestamp(), "24h"))}T08:00:00+01:00"
}

resource "azurerm_automation_job_schedule" "start_vms_schedule" {
  resource_group_name     = azurerm_resource_group.range.name
  automation_account_name = azurerm_automation_account.range.name
  schedule_name            = azurerm_automation_schedule.morning_start.name
  runbook_name             = azurerm_automation_runbook.start_vms.name

  lifecycle {
    ignore_changes = [schedule_name]
  }
}