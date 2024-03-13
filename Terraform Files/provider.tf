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
