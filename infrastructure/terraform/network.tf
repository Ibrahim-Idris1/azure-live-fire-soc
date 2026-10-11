resource "azurerm_virtual_network" "range" {
  name                = "vnet-${var.prefix}"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.range.location
  resource_group_name = azurerm_resource_group.range.name
}

resource "azurerm_subnet" "targets" {
  name                 = "snet-targets"
  resource_group_name  = azurerm_resource_group.range.name
  virtual_network_name = azurerm_virtual_network.range.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_network_security_group" "targets" {
  name                = "nsg-targets"
  location            = azurerm_resource_group.range.location
  resource_group_name = azurerm_resource_group.range.name

  # Allow logging traffic out 
  security_rule {
    name                       = "allow-azuremonitor-out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureMonitor"
  }

  # Block everything else heading to the internet
  security_rule {
    name                       = "deny-internet-out"
    priority                   = 4000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
  #Onlly allow my ip in the network
  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.ssh_open_to_internet ? "*" : null
    source_address_prefixes    = var.ssh_open_to_internet ? null : var.admin_source_ips
    destination_address_prefix = "*"
  }
  #Allow Updates 
  dynamic "security_rule" {
    for_each = var.allow_updates_outbound ? [1] : []
    content {
      name                       = "allow-web-out-temp"
      priority                   = 200
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = ["80", "443"]
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  }
  security_rule {
    name                       = "allow-rdp"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.rdp_open_to_internet ? "*" : null
    source_address_prefixes    = var.rdp_open_to_internet ? null : var.admin_source_ips
    destination_address_prefix = "*"
  }


}


resource "azurerm_subnet_network_security_group_association" "targets" {
  subnet_id                 = azurerm_subnet.targets.id
  network_security_group_id = azurerm_network_security_group.targets.id
}

