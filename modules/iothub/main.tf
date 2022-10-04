data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name
}

resource "azurerm_iothub" "iothub" {
  name                          = var.iothub_name
  resource_group_name           = var.resource_group_name
  location                      = var.resource_group_location
  public_network_access_enabled = false
  sku {
    name     = var.iothub_tier
    capacity = var.iothub_units
  }
  fallback_route {
    source         = "DeviceMessages"
    endpoint_names = ["events"]
    enabled        = true
  }
}
output "iothub_id" {
  value = azurerm_iothub.iothub.id
}
resource "azurerm_private_dns_zone" "iotdns" {
  name                = "privatelink.azure-devices.net"
  resource_group_name = var.resource_group_name
}
resource "azurerm_private_dns_zone" "sbdns" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_endpoint" "iotpe" {
  name                = var.iothub_private_endpoint_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.subnet.id

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.iotdns.id, azurerm_private_dns_zone.sbdns.id]
  }
  private_service_connection {
    name                           = var.iothub_private_endpoint_name
    private_connection_resource_id = azurerm_iothub.iothub.id
    is_manual_connection           = false
    subresource_names              = ["iotHub"]
  }
}
