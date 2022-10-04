data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name
}
data "azurerm_subscription" "current" {
}

resource "azurerm_cosmosdb_account" "cosmos" {
  name                              = var.cosmosdb_name
  location                          = var.resource_group_location
  resource_group_name               = var.resource_group_name
  offer_type                        = "Standard"
  kind                              = "GlobalDocumentDB"
  is_virtual_network_filter_enabled = true
  enable_free_tier                  = false

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.resource_group_location
    failover_priority = 0
  }
  key_vault_key_id = "https://${var.key_vault_name}.vault.azure.net/keys/${var.key_vault_key_name}"

  identity {
    type = "SystemAssigned"
  }
  provisioner "local-exec" {
    command = "az role assignment create --role \"Key Vault Crypto Service Encryption User\" --assignee ${azurerm_cosmosdb_account.cosmos.identity[0].principal_id} --scope /subscriptions/${data.azurerm_subscription.current.subscription_id}/resourcegroups/${var.resource_group_name}/providers/Microsoft.KeyVault/vaults/${var.key_vault_name}/keys/${var.key_vault_key_name}"
  }
  provisioner "local-exec" {
    command = "az role assignment delete --role \"Key Vault Crypto Service Encryption User\" --assignee \"a232010e-820c-4083-83bb-3ace5fc29d0b\" --scope /subscriptions/${data.azurerm_subscription.current.subscription_id}/resourcegroups/${var.resource_group_name}/providers/Microsoft.KeyVault/vaults/${var.key_vault_name}/keys/${var.key_vault_key_name}"
  }
}

output "cosmosdb_id" {
  value = azurerm_cosmosdb_account.cosmos.id
}

resource "azurerm_private_dns_zone" "cosmosdns" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_endpoint" "cosmospe" {
  name                = var.cosmos_private_endpoint_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.subnet.id

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.cosmosdns.id]
  }
  private_service_connection {
    name                           = var.cosmos_private_endpoint_name
    private_connection_resource_id = azurerm_cosmosdb_account.cosmos.id
    is_manual_connection           = false
    subresource_names              = ["sql"]
  }
  provisioner "local-exec" {
    command = "az cosmosdb update -n ${azurerm_cosmosdb_account.cosmos.name} -g ${var.resource_group_name} --virtual-network-rules ${data.azurerm_subnet.subnet.id}"
  }
}

