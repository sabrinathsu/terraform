resource "azurerm_cdn_frontdoor_origin_group" "origin_group" {
  name                     = var.origin_group_name
  cdn_frontdoor_profile_id = var.profile_id

  dynamic "health_probe" {
    for_each = var.health_probe == null ? [] : [1]

    content{
      protocol            = var.each.value.protocol
      interval_in_seconds = var.each.value.interval_in_seconds
      request_type        = var.each.value.request_type
      path                = var.each.value.path
    }
  }

  load_balancing{
    additional_latency_in_milliseconds = var.load_balancing.additional_latency_in_milliseconds
    sample_size = var.load_balancing.sample_size
    successful_samples_required = var.load_balancing.successful_samples_required
  }

}

resource "azurerm_cdn_frontdoor_origin" "example" {

  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id

  for_each = var.origins
  name     = each.value.name

  enabled                        = each.value.enabled
  certificate_name_check_enabled = each.value.certificate_name_check_enabled

  host_name          = each.value.host_name
  origin_host_header = each.value.origin_host_header
  priority           = each.value.priority
  weight             = each.value.weight

  http_port  = each.value.http_port
  https_port = each.value.https_port

  dynamic "private_link" {
    for_each = each.value.private_link == null ? [] : [1]
    content {
      request_message        = "Request access for Private Link Origin CDN Frontdoor"
      target_type            = each.value.private_link.target_type
      location               = each.value.private_link.location
      private_link_target_id = each.value.private_link.private_link_target_id
    }
  }
}
