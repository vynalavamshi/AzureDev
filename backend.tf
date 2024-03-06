# how to create a bckend file
terraform {
  backend "azurerm" {
    resource_group_name = "Myv_Resource" 
    storage_account_name = "vmcstorageaccount"
    container_name = "datafiles"
    key = "datafiles.terraform.tfstate"

  }
}

