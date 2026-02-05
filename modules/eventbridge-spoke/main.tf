locals {
  regions = toset(concat(["us-east-1"], var.regions))
}

resource "aws_cloudwatch_event_rule" "forward_cloudtrail" {
  for_each = local.regions

  name           = "forward-cloudtrail-to-hub-${each.key}"
  description    = "Forward CloudTrail API events to hub bus"
  event_bus_name = "default"

  event_pattern = jsonencode({
    "detail-type" = [
      "AWS API Call via CloudTrail",
      "AWS Console Sign In via CloudTrail"
    ],
    "source" = [{ "prefix" = "aws." }]
  })

  region = each.key
}

resource "aws_cloudwatch_event_target" "forward_cloudtrail_to_hub" {
  for_each = local.regions

  rule           = aws_cloudwatch_event_rule.forward_cloudtrail[each.key].name
  event_bus_name = "default"

  target_id = "to-hub-bus"
  arn       = var.eventbridge_hub_arn
  role_arn  = module.eventbridge_forwarder_role.arn

  region = each.key
}

module "eventbridge_forwarder_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "6.4.0"

  name   = "eventbridge-forward-to-hub"
  policy = data.aws_iam_policy_document.eventbridge_forwarder.json
}

module "eventbridge_forwarder_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "6.4.0"

  name = "eventbridge-forward-to-hub"

  trust_policy_permissions = {
    eventbridge_assume = {
      effect  = "Allow"
      actions = ["sts:AssumeRole"]

      principals = {
        service = ["events.amazonaws.com"]
      }

      conditions = [
        {
          test     = "StringEquals"
          variable = "aws:SourceAccount"
          values   = [data.aws_caller_identity.current.account_id]
        },
        {
          test     = "ArnEquals"
          variable = "aws:SourceArn"
          values   = [for region in local.regions : aws_cloudwatch_event_rule.forward_cloudtrail[region].arn]
        }
      ]
    }
  }

  policies = {
    forward_to_hub = module.eventbridge_forwarder_policy.arn
  }
}
