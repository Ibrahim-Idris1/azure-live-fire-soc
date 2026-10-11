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
  disable_password_authentication = true
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