resource "azurerm_public_ip" "linux01" {
  name                = "pip-linux-01"
  location            = azurerm_resource_group.range.location
  resource_group_name = azurerm_resource_group.range.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "linux01" {
  name                = "nic-linux-01"
  location            = azurerm_resource_group.range.location
  resource_group_name = azurerm_resource_group.range.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.targets.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux01.id
  }
}

resource "azurerm_linux_virtual_machine" "linux01" {
  name                            = "vm-linux-01"
  location                        = azurerm_resource_group.range.location
  resource_group_name             = azurerm_resource_group.range.name
  size                            = var.vm_size
  admin_username                  = "socadmin"
  disable_password_authentication = !var.enable_password_login
  admin_password                  = var.enable_password_login ? var.admin_password : null
  network_interface_ids           = [azurerm_network_interface.linux01.id]

  admin_ssh_key {
    username   = "socadmin"
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Required by the Azure Monitor Agent. Do NOT assign any roles to it.
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_virtual_machine_extension" "vulns_linux01" {
  count                = var.plant_vulnerabilities ? 1 : 0
  name                 = "PlantVulnerabilities"
  virtual_machine_id   = azurerm_linux_virtual_machine.linux01.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  protected_settings = jsonencode({
    script = base64encode(file("${path.module}/../vulnerabilities/linux/plant-vulns.sh"))
  })

  depends_on = [azurerm_virtual_machine_extension.ama_linux01]
}