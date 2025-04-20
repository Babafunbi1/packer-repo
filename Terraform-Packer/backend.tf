terraform {

    backend "azurerm" {
        resource_group_name  = "tfstaterg"
        storage_account_name = "babafunbi3307"
        container_name       = "tfstate"
        key                  = "demo.terraform.tfstate"
    }
}