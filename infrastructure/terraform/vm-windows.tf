resource "azurerm_public_ip" "win01" {
  name                = "pip-win-01"
  location            = azurerm_resource_group.range.location
  resource_group_name = azurerm_resource_group.range.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "win01" {
  name                = "nic-win-01"
  location            = azurerm_resource_group.range.location
  resource_group_name = azurerm_resource_group.range.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.targets.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.win01.id
  }
}

resource "azurerm_windows_virtual_machine" "win01" {
  name                  = "vm-win-01"
  location              = azurerm_resource_group.range.location
  resource_group_name   = azurerm_resource_group.range.name
  size                  = var.windows_vm_size
  admin_username        = "socadmin"
  admin_password        = var.windows_admin_password
  network_interface_ids = [azurerm_network_interface.win01.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

  # Required by the Azure Monitor Agent. Do NOT assign any roles to it.
  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [admin_password]
  }
}

output "win01_public_ip" {
  value = azurerm_public_ip.win01.ip_address
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "win01" {
  virtual_machine_id    = azurerm_windows_virtual_machine.win01.id
  location              = azurerm_resource_group.range.location
  enabled               = var.auto_shutdown_enabled
  daily_recurrence_time = "2300"
  timezone              = "W. Central Africa Standard Time"

  notification_settings {
    enabled = false
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "linux01" {
  virtual_machine_id    = azurerm_linux_virtual_machine.linux01.id
  location              = azurerm_resource_group.range.location
  enabled               = var.auto_shutdown_enabled
  daily_recurrence_time = "2300"
  timezone              = "W. Central Africa Standard Time"

  notification_settings {
    enabled = false
  }
}

locals {
  windows_provision_script = join("\n", compact([
    file("${path.module}/../windows/install-sysmon.ps1"),
    var.plant_vulnerabilities ? file("${path.module}/../vulnerabilities/windows/plant-vulns.ps1") : ""
  ]))
}

resource "azurerm_virtual_machine_extension" "sysmon_win01" {
  name                 = "InstallSysmon"
  virtual_machine_id   = azurerm_windows_virtual_machine.win01.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    commandToExecute = "powershell -ExecutionPolicy Bypass -EncodedCommand ${textencodebase64(local.windows_provision_script, "UTF-16LE")}"
  })

  depends_on = [
    azurerm_network_security_group.targets,
    azurerm_virtual_machine_extension.ama_win01
  ]
}