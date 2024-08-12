terraform {
  backend "azurerm" {
    resource_group_name   = "deployment"   
    storage_account_name  = "terraformstatehomework"    
    container_name        = "tfstate"                    
    key                   = "terraform.tfstate"          
  }
}
