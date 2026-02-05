variable "eventbridge_hub_arn" {
  description = "ARN of central EventBridge Event Bus."
  type        = string
}

variable "regions" {
  description = "List of regions to create spoke resources in."
  type        = list(string)
  default     = []
}