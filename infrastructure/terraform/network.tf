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
    name                       = "allow-ssh-admin"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.admin_source_ips
    destination_address_prefix = "*"
  }
}


resource "azurerm_subnet_network_security_group_association" "targets" {
  subnet_id                 = azurerm_subnet.targets.id
  network_security_group_id = azurerm_network_security_group.targets.id
}

