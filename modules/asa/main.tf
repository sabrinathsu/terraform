data "azurerm_subscription" "current" {
}

resource "azurerm_template_deployment" "asa_cluster" {
  name                = var.asa_cluster_name
  resource_group_name = var.resource_group_name

  template_body = file("./templates/asacluster.json")


  # these key-value pairs are passed into the ARM Template's `parameters` block
  parameters = {
    "location"    = var.resource_group_location,
    "clusterName" = var.asa_cluster_name,
    "iothub_id"   = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Devices/IotHubs/${var.iothub_name}",
    "cosmosdb_id" = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.DocumentDB/databaseAccounts/${var.cosmosdb_name}"
  }

  deployment_mode = "Incremental"
}

resource "azurerm_template_deployment" "asa_job" {
  name                = var.asa_job_name
  resource_group_name = var.resource_group_name

  template_body = file("./templates/asajob.json")


  # these key-value pairs are passed into the ARM Template's `parameters` block
  parameters = {
    "location"   = var.resource_group_location,
    "jobName"    = var.asa_job_name,
    "cluster_id" = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.StreamAnalytics/clusters/${var.asa_cluster_name}"
  }

  deployment_mode = "Incremental"
  depends_on = [
    azurerm_template_deployment.asa_cluster
  ]
}


