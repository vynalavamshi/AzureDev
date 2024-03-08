
# variable "storage_account_name" {
#   type =  string
#   description = "Enter Storage Account name plz!"
# }  this is a method by using variablees we can re utilise where req this variables.

# locals {
#   resource_group_name = "Myv_Resource"
#   location            = " East US"
# }


# #How to create a Resource group
# resource "azurerm_resource_group" "rg1" {
#   #name = "MyFirst_Resource"
#   name = local.resource_group_name #other way by using locals
#   #location = "East US"  # this are the Arguments
#   location = local.location #other way by using locals
#   #tags are optional here
# }


#resources Creation block code...
resource "azurerm_resource_group" "Sample_Resource" {
  name     = "${var.Rname}-resources"
  location = "East US"
}


#How to create a Virtual Machine
resource "azurerm_virtual_network" "Virtual_Machine_main" {
  name                = "vmachinedz"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.Sample_Resource.location
  resource_group_name = azurerm_resource_group.Sample_Resource.name
}

resource "azurerm_subnet" "Subnet" {
  name                 = "subnetspace"
  resource_group_name  = azurerm_resource_group.Sample_Resource.name
  virtual_network_name = azurerm_virtual_network.Virtual_Machine_main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "Interface_Space" {
  name                = "interfacespace"
  location            = azurerm_resource_group.Sample_Resource.location
  resource_group_name = azurerm_resource_group.Sample_Resource.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.Subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "Virtual_Machine_Space" {
  name                = "vmspace"
  resource_group_name = azurerm_resource_group.Sample_Resource.name
  location            = azurerm_resource_group.Sample_Resource.location
  size                = "Standard_F2"
  admin_username      = "vamshi"
  admin_password      = "Vmc@6678"
  network_interface_ids = [
    azurerm_network_interface.Interface_Space.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

#Storage Account Creating...
resource "azurerm_storage_account" "Storage_Account" {
  name                     = "mystreaccount"
  resource_group_name      = azurerm_resource_group.Sample_Resource.name
  location                 = azurerm_resource_group.Sample_Resource.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

#Container Creation here...
resource "azurerm_storage_container" "Storage_Container" {
  name                  = "submanagercontainer"
  storage_account_name  = azurerm_storage_account.Storage_Account.name
  container_access_type = "private"
  depends_on = [ azurerm_storage_account.Storage_Account ]
}

#Blob Creation...
resource "azurerm_storage_blob" "Blob" {
  name                   = "files.zip"
  storage_account_name   = azurerm_storage_account.Storage_Account.name
  storage_container_name = azurerm_storage_container.Storage_Container.name
  type                   = "Block"
  source                 = "sample.zip"
}

# #Backend file creation
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "demo-resources"
#     storage_account_name = "storage_account_name"
#     container_name       = "tfstate"
#     key                  = "prod.terraform.tfstate"
#   }
# }