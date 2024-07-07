# ------------------------------------------------------------------------------
# MAWS Step Function State Machine
# ------------------------------------------------------------------------------

locals {
  state_machine_id = "${local.id}-sfn"
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = local.state_machine_id
  role_arn = aws_iam_role.iam_for_sfn.arn

  definition = <<EOF
{
  "Comment": "A Hello World example of the Amazon States Language using an AWS Lambda Function",
  "StartAt": "HelloWorld",
  "States": {
    "HelloWorld": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.lambda.arn}",
      "End": true
    }
  }
}
EOF

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.sfn.arn}:*"
    include_execution_data = true
    level                  = "ERROR"
  }
}

resource "aws_cloudwatch_log_group" "sfn" {
  name = state_machine_id

  tags = local.tags
}