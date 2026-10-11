output "linux01_public_ip" {
  value = azurerm_public_ip.linux01.ip_address
}