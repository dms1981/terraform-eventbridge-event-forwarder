output "eventbridge_hub_bus" {
  description = "The EventBridge bus created in the hub account to receive forwarded events."
  value       = module.hub_bus
}
