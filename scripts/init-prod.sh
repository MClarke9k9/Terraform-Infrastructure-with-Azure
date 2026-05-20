#!/usr/bin/env bash
set -euo pipefail
terraform init \
  -backend-config="resource_group_name=rg-tfstate" \
  -backend-config="storage_account_name=REPLACE_WITH_STORAGE_ACCOUNT" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=prod.terraform.tfstate"
