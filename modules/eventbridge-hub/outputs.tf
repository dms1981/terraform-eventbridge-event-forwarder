output "eventbridge_hub_bus" {
  description = "The EventBridge bus created in the hub account to receive forwarded events."
  value       = aws_cloudwatch_event_bus.hub_bus
}
