output "eventbridge_forwarder_policy" {
  description = "Module created to hold policy for EventBridge forwarder role."
  value       = module.eventbridge_forwarder_policy
}

output "eventbridge_forwarder_role" {
  description = "Module created for EventBridge to assume when forwarding events to the hub bus."
  value       = module.eventbridge_forwarder_role
}

output "eventbridge_event_rule" {
  description = "CloudWatch Event Rules created to forward CloudTrail events."
  value       = aws_cloudwatch_event_rule.forward_cloudtrail
}

output "eventbridge_event_target" {
  description = "CloudWatch Event Target to send events to the hub bus."
  value       = aws_cloudwatch_event_target.forward_cloudtrail_to_hub
}
