terraform {
  backend "azurerm" {
    resource_group_name  = "bestresource-resources"
    storage_account_name = "mystreaccount"
    container_name       = "submanagercontainer"
    key                  = "submanagercontainer.terraform.tfstate"
  }
}
