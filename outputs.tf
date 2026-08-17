output "container_app_name" {
  value = azurerm_container_app.this.name
}

output "container_app_url" {
  value = "https://${azurerm_container_app.this.ingress[0].fqdn}"
}

output "container_app_fqdn" {
  value = azurerm_container_app.this.ingress[0].fqdn
}

output "key_vault_name" {
  value = azurerm_key_vault.this.name
}

output "image" {
  value = "${var.image_name}:${var.image_tag}"
}