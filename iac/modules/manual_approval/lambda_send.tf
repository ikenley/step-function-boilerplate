#-------------------------------------------------------------------------------
# Function which sends the mamnual approval email
#-------------------------------------------------------------------------------

locals {
  send_lambda_id = "${local.id}-send"
}

module "send_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = local.send_lambda_id
  description   = "${local.id} send manual approve message"
  handler       = "lambda_function.handler"
  runtime       = "nodejs20.x"
  publish       = true
  timeout       = 30 # seconds

  source_path = "${path.module}/lambda/send-lambda/src"

  policy = aws_iam_policy.send_lambda.arn

  #vpc_subnet_ids         = var.private_subnets # var.public_subnets #
  #vpc_security_group_ids = [aws_security_group.revisit_prediction.id]
  #attach_network_policy  = true

  environment_variables = {
    Serverless = "Terraform"
    #SES_EMAIL_ADDRESS        = var.ses_email_address
  }

  tags = local.tags
}

resource "aws_iam_policy" "send_lambda" {
  name        = local.send_lambda_id
  path        = "/"
  description = "Main policy for ${local.send_lambda_id}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid": "Logging",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:*:*:*",
        "Effect" : "Allow"
      },
      {
        "Sid": "Sns"
        "Action" : [
          "SNS:Publish"
        ],
        "Resource" : [
          aws_sns_topic.sns_human_approval_email_topic.arn
        ],
        "Effect" : "Allow"
      }
    ]
  })
}


resource "aws_sns_topic" "sns_human_approval_email_topic" {
  name = local.id

  kms_master_key_id = "alias/aws/sns"
}
