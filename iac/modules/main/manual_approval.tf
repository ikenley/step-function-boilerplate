#-------------------------------------------------------------------------------
# Manual Approval step
#-------------------------------------------------------------------------------

locals {
  manual_approval_id = "${var.namespace}-${var.env}-manual-approve"
  manual_approval_sfn_id = "${local.manual_approval_id}-sfn"
}

module "manual_approval" {
  source = "../manual_approval"

  namespace    = var.namespace
  env          = var.env
  is_prod      = var.is_prod

  ses_email_addresses = var.ses_email_addresses

  sns_topic_arns = [aws_sns_topic.ai_sfn.arn]

}

resource "aws_sfn_state_machine" "manual_approval_sfn" {
  name     = local.manual_approval_sfn_id
  role_arn = aws_iam_role.manual_approval_sfn.arn

  definition = <<EOF
{
  "StartAt": "manual_approve_lambda",
  "TimeoutSeconds": 3600,
  "States": {
    "manual_approve_lambda": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke.waitForTaskToken",
      "Parameters": {
        "FunctionName": "${module.manual_approval.send_lambda_function_arn}",
        "Payload": {
          "ExecutionContext.$": "$$",
          "APIGatewayEndpoint": "${module.manual_approval.api_gateway_invoke_url}",
          "EmailSnsTopic": "${module.manual_approval.sns_email_topic_arn}"
        }
      },
      "Next": "manual_approve_choice_state"
    },
    "manual_approve_choice_state": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.action",
          "StringEquals": "approve",
          "Next": "approved_pass_state"
        },
        {
          "Variable": "$.action",
          "StringEquals": "reject",
          "Next": "rejected_pass_state"
        }
      ]
    },
    "approved_pass_state": {
      "Type": "Pass",
      "End": true
    },
    "rejected_pass_state": {
      "Type": "Pass",
      "End": true
    }
  }
}
EOF

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.manual_approval_sfn.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }
}

resource "aws_cloudwatch_log_group" "manual_approval_sfn" {
  name = local.manual_approval_sfn_id

  tags = local.tags
}

resource "aws_iam_role" "manual_approval_sfn" {
  name = local.manual_approval_sfn_id
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "states.amazonaws.com"
        }
      },
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "manual_approval_sfn" {
  role       = aws_iam_role.manual_approval_sfn.name
  policy_arn = aws_iam_policy.manual_approval_sfn.arn
}

resource "aws_iam_policy" "manual_approval_sfn" {
  name        = local.manual_approval_sfn_id
  path        = "/"
  description = "Main policy for ${local.manual_approval_sfn_id}"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Cloudwatch",
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "xray",
        "Effect" : "Allow",
        "Action" : [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets"
        ],
        "Resource" : [
          "*"
        ]
      },
      {
        "Sid" : "InvokeLambda",
        "Effect" : "Allow",
        "Action" : [
          "lambda:InvokeFunction"
        ],
        "Resource" : [
          "${module.manual_approval.send_lambda_function_arn}",
          "${module.manual_approval.send_lambda_function_arn}:*"
        ]
      }
    ]
  })
}