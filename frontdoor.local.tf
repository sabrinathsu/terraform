locals {
  frontdoor = {
    origins = {
      blobstorage = {
        origins = {
          "1"={
            name = "devst0001"
            host_name          = "devst0001.blob.core.windows.net"
            origin_host_header = "devst0001.blob.core.windows.net"
            private_link = {
              request_message        = "Request access for Private Link Origin CDN Frontdoor"
              target_type            = "blob"
              location               = "eastus"
              private_link_target_id = "/subscriptions/629a1c29-e2d8-415e-bd9f-f094b51aff9e/resourceGroups/dev/providers/Microsoft.Storage/storageAccounts/devst0001"
            }
          }
        }
      }
    }
  }
}
