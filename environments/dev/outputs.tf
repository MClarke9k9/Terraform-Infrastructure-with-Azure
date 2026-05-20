output "resource_group_name" { value = azurerm_resource_group.this.name }
output "vnet_name" { value = module.network.vnet_name }
output "nsg_name" { value = module.network.nsg_name }
output "vm_name" { value = module.linux_vm.vm_name }
output "public_ip_address" { value = module.linux_vm.public_ip_address }
output "log_analytics_workspace_id" { value = module.monitoring.workspace_id }
