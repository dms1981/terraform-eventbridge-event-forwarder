data "aws_regions" "available" {}

data "aws_orgs_organization" "current" {}

module "eventbridge_hub_with_account_access" {
  source = "../../modules/eventbridge-hub"

  bus_name       = "hub-bus"
  account_access = ["123456789012", "210987654321"]
}

module "eventbridge_hub_with_org_access" {
  source = "../../modules/eventbridge-hub"

  bus_name            = "hub-bus"
  organisation_access = data.aws_orgs_organization.current.organization_id
}

module "event_forwarder" {
  source    = "../modules/eventbridge-spoke"
  providers = { aws = aws.spoke }

  eventbridge_hub_arn = module.eventbridge_hub_with_account_access.eventbridge_hub_bus_arn
  #eventbridge_hub_arn = module.eventbridge_hub_with_org_access.eventbridge_hub_bus_arn
  regions = data.aws_regions.available.names
}
