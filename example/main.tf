data "aws_regions" "available" {}

module "event_forwarder" {
  source = "../modules/eventbridge-spoke"
  eventbridge_hub_arn = "arn:aws:events:us-east-1:123456789012:event-bus/hub-bus"
  regions = data.aws_regions.available.names
}
