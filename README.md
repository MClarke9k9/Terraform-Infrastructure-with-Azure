# Azure Terraform Infrastructure Project

Azure infrastructure using Terraform modules, remote state, state locking, and separate dev/prod environments.

## Architecture

This will deploy:

- Resource group per environment
- Virtual network and subnet
- Network Security Group with SSH restricted by CIDR
- Ubuntu Linux VM
- Public IP and NIC
- Log Analytics Workspace
- Azure Blob Storage backend for remote Terraform state

## Repository Structure

```text
azure-terraform-infrastructure/
├── bootstrap/              # Creates remote state resource group, storage account, and container
├── environments/
│   ├── dev/                # Dev environment root module
│   └── prod/               # Prod environment root module
├── modules/
│   ├── network/            # VNet, subnet, NSG
│   ├── linux-vm/           # VM, NIC, public IP
│   └── monitoring/         # Log Analytics Workspace
└── scripts/                # Backend init helpers
```

## Prerequisites

- Azure CLI
- Terraform 1.6+
- Azure subscription access
- SSH key pair

Login:

```bash
az login
az account set --subscription "<subscription-id>"
```

Create SSH key if needed:

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
```

## Step 1: Create Remote State Backend

```bash
cd bootstrap
terraform init
terraform plan
terraform apply
```

Copy the output value for `backend_storage_account_name`.

## Step 2: Configure Dev Backend

```bash
cd ../environments/dev
cp dev.tfvars.example dev.tfvars
```

Edit `dev.tfvars` and replace:

```text
YOUR_PUBLIC_IP/32
```

Get your public IP:

```bash
curl ifconfig.me
```

Initialize backend:

```bash
terraform init \
  -backend-config="resource_group_name=rg-tfstate" \
  -backend-config="storage_account_name=<backend-storage-account-name>" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=dev.terraform.tfstate"
```

Deploy dev:

```bash
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

## Step 3: Configure Prod Backend

```bash
cd ../prod
cp prod.tfvars.example prod.tfvars
```

Initialize backend with a separate state key:

```bash
terraform init \
  -backend-config="resource_group_name=rg-tfstate" \
  -backend-config="storage_account_name=<backend-storage-account-name>" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=prod.terraform.tfstate"
```

Deploy prod:

```bash
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```

## Remote State and Locking

The `azurerm` backend stores each environment state file in Azure Blob Storage.

State files are separated by backend key:

- `dev.terraform.tfstate`
- `prod.terraform.tfstate`

Azure Blob Storage backend supports state locking, which helps prevent two Terraform operations from modifying the same state at the same time.

## Validate Resources

```bash
az group list --query "[?contains(name, 'cloudinfra')].name" -o table
az vm list -g rg-cloudinfra-dev -o table
az network vnet list -g rg-cloudinfra-dev -o table
az monitor log-analytics workspace list -g rg-cloudinfra-dev -o table
```

## Cleanup

Destroy environments first:

```bash
cd environments/dev
terraform destroy -var-file="dev.tfvars"

cd ../prod
terraform destroy -var-file="prod.tfvars"
```

Then destroy the backend only after all environment state is no longer needed:

```bash
cd ../../bootstrap
terraform destroy
```


