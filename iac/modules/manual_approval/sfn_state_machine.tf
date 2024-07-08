# #-------------------------------------------------------------------------------
# # Step Function definition
# #-------------------------------------------------------------------------------

# # TODO move this to parent module

# # resource "aws_sfn_state_machine" "human_approval_lambda_state_machine" {
# #   role_arn = aws_iam_role.lambda_state_machine_execution_role.arn
# #   definition = "{
# #     "StartAt": "Lambda Callback",
# #     "TimeoutSeconds": 3600,
# #     "States": {
# #         "Lambda Callback": {
# #             "Type": "Task",
# #             "Resource": "arn:${data.aws_partition.current.partition}:states:::lambda:invoke.waitForTaskToken",
# #             "Parameters": {
# #               "FunctionName": "${aws_lambda_function.lambda_human_approval_send_email_function.arn}",
# #               "Payload": {
# #                 "ExecutionContext.$": "$$",
# #                 "APIGatewayEndpoint": "https://${aws_api_gateway_rest_api.execution_api.arn}.execute-api.${data.aws_region.current.name}.amazonaws.com/states"
# #               }
# #             },
# #             "Next": "ManualApprovalChoiceState"
# #         },
# #         "ManualApprovalChoiceState": {
# #           "Type": "Choice",
# #           "Choices": [
# #             {
# #               "Variable": "$.Status",
# #               "StringEquals": "Approved! Task approved by ${var.email}",
# #               "Next": "ApprovedPassState"
# #             },
# #             {
# #               "Variable": "$.Status",
# #               "StringEquals": "Rejected! Task rejected by ${var.email}",
# #               "Next": "RejectedPassState"
# #             }
# #           ]
# #         },
# #         "ApprovedPassState": {
# #           "Type": "Pass",
# #           "End": true
# #         },
# #         "RejectedPassState": {
# #           "Type": "Pass",
# #           "End": true
# #         }
# #     }
# # }
# # "
# # }

# resource "aws_iam_role" "lambda_state_machine_execution_role" {
#   assume_role_policy = {
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "states.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   }
#   force_detach_policies = [
#     {
#       PolicyName = "InvokeCallbackLambda"
#       PolicyDocument = {
#         Statement = [
#           {
#             Effect = "Allow"
#             Action = [
#               "lambda:InvokeFunction"
#             ]
#             Resource = [
#               "${aws_lambda_function.lambda_human_approval_send_email_function.arn}"
#             ]
#           }
#         ]
#       }
#     }
#   ]
# }