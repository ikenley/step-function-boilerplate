#-------------------------------------------------------------------------------
# Lambda Function which handle ai image generation.
#-------------------------------------------------------------------------------

locals {
  ai_image_lambda_id = "${local.id}-ai-image-lambda"
}

module "ai_image_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = local.ai_image_lambda_id
  description   = "${local.id} AI image generation"
  handler       = "lambda_function.handler"
  runtime       = "nodejs20.x"
  publish       = true
  timeout       = 30 # seconds

  source_path = "${path.module}/lambda/ai-image/src"

  #vpc_subnet_ids         = var.private_subnets # var.public_subnets #
  #vpc_security_group_ids = [aws_security_group.revisit_prediction.id]
  #attach_network_policy  = true

  environment_variables = {
    Serverless = "Terraform"
    #SES_EMAIL_ADDRESS        = var.ses_email_address
  }

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ai_image_lambda_main" {
  role       = module.ai_image_lambda.lambda_role_name
  policy_arn = aws_iam_policy.ai_image_lambda_main.arn
}

resource "aws_iam_policy" "ai_image_lambda_main" {
  name        = local.ai_image_lambda_id
  path        = "/"
  description = "Main policy for ${local.ai_image_lambda_id}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Logging",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:*:*:*",
        "Effect" : "Allow"
      }
    ]
  })
}
