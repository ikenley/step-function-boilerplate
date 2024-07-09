# ------------------------------------------------------------------------------
# sfn_state_machine.tf
# ------------------------------------------------------------------------------

resource "aws_ssm_parameter" "api_gateway_invoke_url" {
  name  = "${local.output_prefix}/api_gateway_invoke_url"
  type  = "String"
  value = "https://${aws_api_gateway_rest_api.api_gateway.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.api_gateway.stage_name}"
}

output "api_gateway_invoke_url" {
  value = "https://${aws_api_gateway_rest_api.api_gateway.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.api_gateway.stage_name}"
}

# resource "aws_ssm_parameter" "state_machine_human_approval_arn" {
#   name  = "${local.output_prefix}/state_machine_human_approval_arn"
#   type  = "String"
#   value = aws_sfn_state_machine.human_approval_lambda_state_machine.id
# }
