locals {
  organisation_access_enabled = trim(var.organisation_access) != ""
  account_access_enabled      = length(var.account_access) > 0
}

variable "organisation_access" {
  description = "Org ID allowed to put events to the bus. Alternative to account-id access."
  type        = string
  default     = ""
}

variable "account_access" {
  description = "List of account IDs allowed to put events to the bus. Alternative to org-id access."
  type        = list(string)
  default     = []
}

variable "bus_name" {
  description = "Name for the EventBridge bus to create. Must be unique within the region."
  type        = string
  validation {
    condition     = !(local.organisation_access_enabled && local.account_access_enabled)
    error_message = "Cannot enable both organisation and account access simultaneously."
  }
}
