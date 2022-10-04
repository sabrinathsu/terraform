resource "azurerm_cdn_frontdoor_profile" "fdp" {
  name                = var.fd_name
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  tags = var.tags
}