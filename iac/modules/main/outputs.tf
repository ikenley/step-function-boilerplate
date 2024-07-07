# ------------------------------------------------------------------------------
# sfn_state_machine.tf
# ------------------------------------------------------------------------------

resource "aws_ssm_parameter" "sfn_state_machine_arn" {
  name  = "${local.output_prefix}/sfn_state_machine_arn"
  type  = "String"
  value = aws_sfn_state_machine.sfn.arn
}

# resource "aws_ssm_parameter" "revisit_prediction__function_name" {
#   name  = "${local.output_prefix}/revisit_prediction/function_name"
#   type  = "SecureString"
#   value = module.revisit_prediction_lambda.lambda_function_name
# }

# resource "aws_ssm_parameter" "to_email_addresses_json" {
#   name  = "${local.output_prefix}/revisit_news_lambda/to_email_addresses_json"
#   type  = "SecureString"
#   value = "['user@example.net']"

#   # This will managed by an external process
#   lifecycle {
#     ignore_changes = [ value ]
#   }
# }
