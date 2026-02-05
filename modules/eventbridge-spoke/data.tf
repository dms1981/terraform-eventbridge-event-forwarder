data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "eventbridge_forwarder" {
  statement {
    sid       = "PutToHub"
    effect    = "Allow"
    actions   = ["events:PutEvents"]
    resources = [var.eventbridge_hub_arn]
  }
}

data "aws_region" "current" {}
