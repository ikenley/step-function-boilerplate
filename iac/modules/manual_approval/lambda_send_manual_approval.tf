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

# resource "aws_iam_role" "send_lambda" {
#   name = local.send_lambda_id

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "states.amazonaws.com"
#         }
#       },
#     ]
#   })

#   tags = local.tags
# }

# resource "aws_iam_role_policy_attachment" "send_lambda" {
#   role       = aws_iam_role.sfn.name
#   policy_arn = aws_iam_policy.sfn.arn
# }

resource "aws_iam_policy" "send_lambda" {
  name        = local.send_lambda_id
  path        = "/"
  description = "Main policy for ${local.send_lambda_id}"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
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
}
