output "backend_resource_group_name" {
  value = azurerm_resource_group.tfstate.name
}

output "backend_storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "backend_container_name" {
  value = azurerm_storage_container.tfstate.name
}
