terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.25.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}

data "azurerm_subscription" "current" {
}

#front door
module "front_door" {
  source              = "./modules/frontdoor/profile"
  fd_name             = var.fd_name
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
}

module "origin" {
  source              = "./modules/frontdoor/origin"
  profile_id = module.front_door.id

  for_each = local.frontdoor.origins

  origin_group_name = each.key
  origins = each.value.origins

}
#iot hub
# module "private_iothub" {
#   source                       = "./modules/iothub"
#   resource_group_name          = var.resource_group_name
#   resource_group_location      = var.resource_group_location
#   iothub_name                  = var.iothub_name
#   iothub_tier                  = var.iothub_tier
#   iothub_units                 = var.iothub_units
#   virtual_network_name         = var.virtual_network_name
#   subnet_name                  = var.subnet_name
#   iothub_private_endpoint_name = var.iothub_private_endpoint_name
# }
/*
#cosmos db
module "private_cosmos" {
  source                       = "./modules/cosmosdb"
  resource_group_name          = var.resource_group_name
  resource_group_location      = var.resource_group_location
  cosmosdb_name                = var.cosmosdb_name
  virtual_network_name         = var.virtual_network_name
  subnet_name                  = var.subnet_name
  cosmos_private_endpoint_name = var.cosmos_private_endpoint_name
  key_vault_name               = var.key_vault_name
  key_vault_key_name           = var.key_vault_key_name
  depends_on                   = [null_resource.prerequisites]
}

#asa job
module "asa" {
  source                  = "./modules/asa"
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
  asa_job_name            = var.asa_job_name
  asa_cluster_name        = var.asa_cluster_name
  iothub_name             = var.iothub_name
  cosmosdb_name           = var.cosmosdb_name
  depends_on              = [null_resource.prerequisites, module.private_cosmos]
}
*/
