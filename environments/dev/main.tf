locals {
  tags = {
    project     = var.project_name
    environment = var.environment
    owner       = "Mark Clarke"
    managed_by  = "Terraform"
  }
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
  tags     = local.tags
}

module "network" {
  source              = "../../modules/network"
  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  vnet_cidr           = var.vnet_cidr
  subnet_cidr         = var.subnet_cidr
  allowed_ssh_cidr    = var.allowed_ssh_cidr
  tags                = local.tags
}

module "linux_vm" {
  source              = "../../modules/linux-vm"
  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = module.network.subnet_id
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  ssh_public_key_path = var.ssh_public_key_path
  tags                = local.tags
}

module "monitoring" {
  source              = "../../modules/monitoring"
  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  retention_in_days   = var.log_retention_days
  tags                = local.tags
}
