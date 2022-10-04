variable "resource_group_name" {
  type = string
}

variable "fd_name" {
  type = string
}

variable "sku_name" {
  type = string
}

variable "tags" {
  type = map
  default = null
}