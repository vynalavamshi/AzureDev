
# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
} #this part tells about azure provider and version for our azure cloud platform

#credentials of the provider
#Get this credentials from Azure Active Directory (app registration from here you create app to get the credential to provider(like a application object))
provider "azurerm" {
  subscription_id = "881c578e-d774-490c-a7fc-f47557a53824"     #getthis id from your subscription (subscription id ))
  client_id       = "134be7df-4248-4821-aa85-f3eced3b4db0"     #(client id is the  application id takes from our azure application)
  client_secret   = "_D68Q~Sz7-iRVZVNPGFIjq.YvU2ltvbVDEB7Pb-c" #generate it from your account
  tenant_id       = "bfdf7180-10df-4529-8656-3289d98f87b9"     #(directory id or tenant id)
  features {}
}


# variable "storage_account_name" {
#   type =  string
#   description = "Enter Storage Account name plz!"
# }  this is a method by using variablees we can re utilise where req this variables.

locals {
  resource_group_name = "Myv_Resource"
  location            = " East US"
}
# data "azurerm_subnet" "mysubnet" {  #it is used to get the ip config address based on subnet in vnetwork to get existing records 
# # data using to get existing records in azure platform and utilise them in terraform script
#   name = "mysubnet"
#   virtual_network_name = "myvnetwork"
#   resource_group_name = local.resource_group_name
# }


#creating a private key to add it to our linux vm because, public key is combination of public & private key.
# resource "tls_private_key" "linux_key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

#we want to save the private key to our machine
#we can then use this key to connect to our Linux VM.
# resource "local_file" "linuxkey" {
#   filename = "linux.pem"
#   content  = tls_private_key.linux_key.private_key_pem
# }

#How to create a Resource group
resource "azurerm_resource_group" "rg1" {
  #name = "MyFirst_Resource"
  name = local.resource_group_name #other way by using locals
  #location = "East US"  # this are the Arguments
  location = local.location #other way by using locals
  #tags are optional here
}

data "azurerm_client_config" "current" {} #this will get the current credentials of provider and resorce and can utilise this in creating a key Vault

#How to create a storage account to store the my resources
resource "azurerm_storage_account" "data_storage_Account" {
  name = "vmcstorageaccount" #this is by hardcoded values...
  #name             = var.storage_account_name    #this is by using variables method
  #resource_group_name      = azurerm_resource_group.rg1.name
  resource_group_name = local.resource_group_name #other way by using locals
  #location              = azurerm_resource_group.rg1.location
  location                 = local.location #other way by using locals
  account_tier             = "Standard"
  account_replication_type = "LRS" #(GRS)geo redundant storage #account Replication type
  depends_on               = [azurerm_resource_group.rg1]

  #allow_blob_public_access = true or false we can  give
  #   tags = {
  #     environment = "staging"
  #   }
}

#Creating a container  is a part in storage Account
resource "azurerm_storage_container" "mystorecontainer" {
  name = "datafiles"
  #storage_account_name  = var.storage_account_name
  storage_account_name  = azurerm_storage_account.data_storage_Account.name
  container_access_type = "private" #access level for that particular container public or private
  #we have  container_access_type are three ,container,private (protected), blob (public by using its urlfrom storage accoutn if we browse that url in chomr we get that file downloaded and we can read that content)
  #depends_on =[ var.storage_account_name ]#it is depends on strorage account hence after execution of storage account code only this code will execute
  depends_on = [azurerm_storage_account.data_storage_Account]
}

#creating a blob in caontainer #blob is a small storage part in container
resource "azurerm_storage_blob" "Myblob" { 
    name      ="sample.txt" #file which we are uploading in that we have content(it can be any file) this file should be present in this files directory such that it will readit
    # storage_account_name   = var.storage_account_name
    storage_account_name   = azurerm_storage_account.dstoreAccount.name
    storage_container_name = azurerm_storage_container.mystorecontainer.name
    type                  ="Block"
    source                 = "sample.txt"
    # depends_on =[var.storage_account_name]
    depends_on =[azurerm_storage_container.mystorecontainer]
#This line mean is it is dependent on container if the container resoucrs is there then only execute this after execution of container resourcecode bcz no gaurantee this will execute nxt or before the container to avoid it we are using this depends on
}

resource "azurerm_storage_blob" "Myblob1_for_Iss_extension" {
  name = "IIS_config.ps" #file which we are uploading in that we have content(it can be any file) this file should be present in this files directory such that it will readit
  # storage_account_name   = var.storage_account_name
  storage_account_name   = azurerm_storage_account.data_storage_Account.name
  storage_container_name = azurerm_storage_container.mystorecontainer.name
  type                   = "Block"
  source                 = "IIS_config.ps"
  # depends_on =[var.storage_account_name]
  depends_on = [azurerm_storage_container.mystorecontainer]
  #This line mean is it is dependent on container if the container resoucrs is there then only execute this after execution of container resourcecode bcz no gaurantee this will execute nxt or before the container to avoid it we are using this depends on
}


#how to create a bckend file
# terraform {
#   backend "azurerm" {
#     resource_group_name = "Myv_Resource" 
#     storage_account_name = "vmcstorageaccount"
#     container_name = "datafiles"
#     key = "datafiles.terraform.tfstate"
    
#   }
# }

# # #how to create virtual network and subnets here...
# resource "azurerm_virtual_network" "vnet" {
#   name                = "myvnetwork"
#   location            = local.location
#   resource_group_name = local.resource_group_name
#   address_space       = ["10.0.0.0/16"]

#   #this is one method for creating subnet
#   # subnet {
#   #   name           = "mysubnet"
#   #   address_prefix = "10.0.1.0/24"
#   # }

# #   # if required additional subnets we can add like this in a same virtual network with mutiple subnets
#     subnet { 
#       name           = "subnet2"
#       address_prefix = "10.0.2.0/24"
#       security_group = azurerm_network_security_group.example.id
#     }

# #   #this is for the enviornment type related will see in up coming videos
# #   #   tags = {
# #   #     environment = "Production"
# #   #   }
# # }
# }

# # #other method for creating subnet
#  resource "azurerm_subnet" "mysubnet_under_VM" {
#   name                 = "mysubnet"
#   resource_group_name  = local.resource_group_name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.0.1.0/24"]
#   depends_on           = [azurerm_virtual_network.vnet]
# }


# # #How to create interface
# resource "azurerm_network_interface" "Myinterface" {
#   name                = "vinterface"
#   location            = local.location
#   resource_group_name = local.resource_group_name

#   ip_configuration { # this will get private ip address it comes from subnet from virtual network
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.mysubnet_under_VM.id #Up data filed s is used to get existing records of subnet and utilising here
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.Mypublicip.id #this is used for adding public Ip address
#   }
#   depends_on = [azurerm_virtual_network.vnet, azurerm_public_ip.Mypublicip, azurerm_subnet.mysubnet_under_VM] #adding depends on PublicIP address & vnet
# }

# # #How to create a virtual machine for windows VM
# resource "azurerm_windows_virtual_machine" "Myvmachine" {
#   name                = "myvmachine"
#   resource_group_name = local.resource_group_name
#   location            = local.location
#   size                = "Standard_F2"
#   admin_username      = "vamshivynala" #this is one method are credentials used to login to our virtual machine 
#   # admin_password      = "Azure@6678"  #this is one method are credentials used to login to our virtual machine
#   # admin_username      = azurerm_key_vault_secret.set_secret_key_vault.name
#   admin_password      = azurerm_key_vault_secret.set_secret_key_vault.value
#   availability_set_id = azurerm_availability_set.My_availability_Set.id #other method get from key vault for more secure purpose.
#   network_interface_ids = [
#     azurerm_network_interface.Myinterface.id,
#   ]

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2019-Datacenter" #version of data center
#     version   = "latest"
#   }
#   depends_on = [azurerm_network_interface.Myinterface, azurerm_availability_set.My_availability_Set, azurerm_key_vault_secret.set_secret_key_vault]
# }




# # #How to create Virtual Machine for Linux VM #after running this run ssh username give enter it will ask for password give password you will login to the linux vm in below cmmondprompt
# resource "azurerm_linux_virtual_machine" "My_Linux_VM" {
#   name                            = "linuxvmachine"
#   resource_group_name             = local.resource_group_name
#   location                        = local.location
#   size                            = "Standard_F2"
#   admin_username                  = "Vamshi"
#   admin_password                  = "Azure@6678"
#   disable_password_authentication = false
#   network_interface_ids = [
#     azurerm_network_interface.Myinterface.id
#   ]
#   #basicaly we use private key for authentication 
#   admin_ssh_key {
#     username   = "Vamshi"
#     public_key = tls_private_key.linux_key.public_key_openssh #it is combination of public and private for authentication to login to linux vm
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts"
#     version   = "latest"
#   }
#   depends_on = [azurerm_network_interface.Myinterface, tls_private_key.linux_key]
# }




# # #How to Create public IP Address
# # # we can connect to virtual machine only if we have a public IP address this helps to interact OS to inteface to virtual machine to network
# resource "azurerm_public_ip" "Mypublicip" {
#   name                = "mypublicipadd"
#   resource_group_name = local.resource_group_name
#   location            = local.location
#   allocation_method   = "Static"
#   depends_on          = [local.resource_group_name]
# }


# # #How to create a Data Disk into virtual machine for data or Installed applications storage purpose
# resource "azurerm_managed_disk" "data_disk" {
#   name                 = "mydatadisk"
#   location             = local.location
#   resource_group_name  = local.resource_group_name
#   storage_account_type = "Standard_LRS"
#   create_option        = "Empty"
#   disk_size_gb         = "16"

#   # tags = {
#   #   environment = "staging"
#   # }
# }

# # #After we creating we need to attach this to the virtual machine so 
# # #How to attach data disk to the virtual machine
# resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_attach" {
#   managed_disk_id    = azurerm_managed_disk.data_disk.id             #get here data_disk id
#   virtual_machine_id = azurerm_windows_virtual_machine.Myvmachine.id #get here MyVM id
#   lun                = "0"                                           #logical unit number  LUN also determines the order in which the disks appear to the virtual machine. For example, if you attach multiple disks to a virtual machine,
#   caching            = "ReadWrite"
#   depends_on         = [azurerm_windows_virtual_machine.Myvmachine, azurerm_managed_disk.data_disk]
# }

# # #how to create a availability set in VM
# resource "azurerm_availability_set" "My_availability_Set" {
#   name                         = "myvmavailabilityset"
#   location                     = local.location
#   resource_group_name          = local.resource_group_name
#   platform_fault_domain_count  = 3
#   platform_update_domain_count = 3

#   # tags = {
#   #   environment = "Production"
#   # }
# }

# # #how to add custom script extensions to setup a web server in virtual machine
# resource "azurerm_virtual_machine_extension" "Web_server_Extension_VM" {
#   name                 = "wsvmextension"
#   virtual_machine_id   = azurerm_windows_virtual_machine.Myvmachine.id
#   publisher            = "Microsoft.Compute"
#   type                 = "CustomScript"
#   type_handler_version = "2.0"
#   depends_on           = [azurerm_storage_blob.Myblob1_for_Iss_extension]
#   settings             = <<SETTINGS
#  {
#    "fileuris" : ["https://${azurerm_storage_account.data_storage_Account.name}.blob.core.windows.net/datafiles/IIS_config.ps"],
#    "commandToExecute" : "powershell - ExecutionPolicy Unrestricted -file IIS_config.ps"
#  }
# SETTINGS

#   # tags = {
#   #   environment = "Production"
#   # }
# }

# # #How to create a security group to a web sever to a virtual machine
# resource "azurerm_network_security_group" "Add_network_security_Group" {
#   name                = "addsecuritygroup"
#   location            = local.location
#   resource_group_name = local.resource_group_name

#   security_rule {
#     name                       = "mysecuritygroup"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "80"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

#   # tags = {
#   #   environment = "Production"
#   # }
# }
# # #Adding up a subnet network security group association here to vm
# resource "azurerm_subnet_network_security_group_association" "example" {
#   subnet_id                 = azurerm_subnet.mysubnet_under_VM.id
#   network_security_group_id = azurerm_network_security_group.Add_network_security_Group.id
#   depends_on                = [azurerm_network_security_group.Add_network_security_Group]
# }

# # #How to create a azure key vault  for vm
# resource "azurerm_key_vault" "Add_key_vault" {
#   name                        = "addkeyvault"
#   location                    = local.location
#   resource_group_name         = local.resource_group_name
#   enabled_for_disk_encryption = true
#   tenant_id                   = data.azurerm_client_config.current.tenant_id
#   soft_delete_retention_days  = 7
#   purge_protection_enabled    = false

#   sku_name = "standard"

#   access_policy {
#     tenant_id = data.azurerm_client_config.current.tenant_id
#     object_id = data.azurerm_client_config.current.object_id

#     key_permissions = [
#       "Get",
#     ]

#     secret_permissions = [
#       "Get",
#     ]

#     storage_permissions = [
#       "Get",
#     ]
#   }
#   depends_on = [local.resource_group_name]
# }

# resource "azurerm_key_vault_secret" "set_secret_key_vault" {
#   name         = "vamshi"
#   value        = "Azure@6678"
#   key_vault_id = azurerm_key_vault.Add_key_vault.id
#   depends_on   = [azurerm_key_vault.Add_key_vault]
# }


