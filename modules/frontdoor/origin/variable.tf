variable "origin_group_name" {
  type = string
}

variable "profile_id" {
  type = string
}

variable "health_probe" {
  type = object({
    protocol            = string
    interval_in_seconds = number
    request_type        = optional(string, "HEAD")
    path                = optional(string, "/")
  })
  default = null
}

variable "load_balancing" {
  type = object({
    additional_latency_in_milliseconds = optional(number, 50)
    sample_size                        = optional(number, 4)
    successful_samples_required        = optional(number, 3)
  })
  default = {
    additional_latency_in_milliseconds = 50
    sample_size = 4
    successful_samples_required = 3
  }
}

variable "origins" {
  type = map(object({
    name                           = string
    enabled                        = optional(bool, true)
    certificate_name_check_enabled = optional(bool, true)

    host_name          = string
    origin_host_header = optional(string)
    priority           = optional(number, 1)
    weight             = optional(number, 500)

    http_port  = optional(number, 80)
    https_port = optional(number, 443)

    private_link = optional(object({
      request_message        = string
      target_type            = string
      location               = string
      private_link_target_id = string
    }), null)
  }))
}

variable "tags" {
  type    = map(any)
  default = null
}
