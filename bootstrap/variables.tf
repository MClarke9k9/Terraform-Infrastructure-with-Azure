variable "resource_group_name" {
  type        = string
  description = "Resource group for Terraform remote state."
  default     = "rg-tfstate"
}

variable "location" {
  type        = string
  description = "Azure region."
  default     = "eastus"
}

variable "container_name" {
  type        = string
  description = "Blob container for Terraform state files."
  default     = "tfstate"
}
