locals {
  bus_permissions = local.organisation_access_enabled ? {
    "* OrgPutEvents" = {
      action         = "events:PutEvents"
      event_bus_name = var.bus_name
      condition_org  = trimspace(var.organisation_access)
    }
  } : local.account_access_enabled ? {
    for acct in var.account_access :
    "${acct} PutEvents" => {
      action         = "events:PutEvents"
      event_bus_name = var.bus_name
    }
  } : {}
}

module "hub_kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 4.2"

  aliases = ["${var.bus_name}/hub-kms"]
  description = "KMS key for EventBridge bus ${var.bus_name}" 
  key_administrators = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
  
  
  key_statements = [
    {
      sid    = "AllowEventBridgeUseOfKeyForEventBuses"
      effect = "Allow"
      principals = [
        {
          type        = "Service"
          identifiers = ["events.amazonaws.com"]
        }
      ]
      actions   = ["kms:DescribeKey", "kms:GenerateDataKey", "kms:Decrypt"]
      resources = ["*"]
      condition = [
        {
          test     = "StringEquals"
          variable = "aws:SourceAccount"
          values   = [data.aws_caller_identity.current.account_id]
        }
      ]
    }
  ]
}

module "hub_dlq" {
  source              = "terraform-aws-modules/sqs/aws"
  version             = "~> 5.0"
  name                = "hub-dlq"
  create_queue_policy = true
  queue_policy_statements = {
    account = {
      sid = "AllowEventBridgeBusToSend"
      actions = [
        "sqs:SendMessage"
      ]
      principals = [{
        type = "Service"
        identifiers = [
          "events.amazonaws.com"
        ]
      }]
      condition = [{
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = [data.aws_caller_identity.current.account_id]
      }]
    }
  }
  use_name_prefix = true
}

module "hub_log_group" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "~> 5.0"

  name              = "/aws/vendedlogs/events/event-bus/${var.bus_name}-bus"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_resource_policy" "hub_log_group" {
  policy_name     = "AllowEventBridgeToWriteToLogGroupForBus${var.bus_name}"
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowEventBridgeToWriteToLogGroupForBus${var.bus_name}"
        Effect    = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action    = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
          ]
        Resource  = [
          module.hub_log_group.cloudwatch_log_group_arn,
          "${module.hub_log_group.cloudwatch_log_group_arn}:*"]
      }
    ]
  })
}

module "hub_bus" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "~>4.0"

  bus_description    = "EventBus to hold CloudTrail events from permitted accounts."
  bus_name           = var.bus_name
  create_permissions = true
  dead_letter_config = {
    arn = module.hub_dlq.queue_arn
  }
  kms_key_identifier = module.hub_kms.key_arn
  log_config = {
    include_detail = "FULL"
    level          = "INFO"
  }
  log_delivery = {
    cloudwatch_logs = {
      destination_arn = module.hub_log_group.cloudwatch_log_group_arn
    }
  }
  permissions = local.bus_permissions

  depends_on = [aws_cloudwatch_log_resource_policy.hub_log_group]
}
