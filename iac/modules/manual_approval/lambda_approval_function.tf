# #-------------------------------------------------------------------------------
# # Lambda Function which handles incoming approve/rejects
# #-------------------------------------------------------------------------------

# # resource "aws_lambda_function" "lambda_approval_function" {
# #   code_signing_config_arn = {
# #     ZipFile = "const { SFN: StepFunctions } = require("@aws-sdk/client-sfn");
# # var redirectToStepFunctions = function(lambdaArn, statemachineName, executionName, callback) {
# #   const lambdaArnTokens = lambdaArn.split(":");
# #   const partition = lambdaArnTokens[1];
# #   const region = lambdaArnTokens[3];
# #   const accountId = lambdaArnTokens[4];

# #   console.log("partition=" + partition);
# #   console.log("region=" + region);
# #   console.log("accountId=" + accountId);

# #   const executionArn = "arn:" + partition + ":states:" + region + ":" + accountId + ":execution:" + statemachineName + ":" + executionName;
# #   console.log("executionArn=" + executionArn);

# #   const url = "https://console.aws.amazon.com/states/home?region=" + region + "#/executions/details/" + executionArn;
# #   callback(null, {
# #       statusCode: 302,
# #       headers: {
# #         Location: url
# #       }
# #   });
# # };

# # exports.handler = (event, context, callback) => {
# #   console.log('Event= ' + JSON.stringify(event));
# #   const action = event.query.action;
# #   const taskToken = event.query.taskToken;
# #   const statemachineName = event.query.sm;
# #   const executionName = event.query.ex;

# #   const stepfunctions = new StepFunctions();

# #   var message = "";

# #   if (action === "approve") {
# #     message = { "Status": "Approved! Task approved by ${var.email}" };
# #   } else if (action === "reject") {
# #     message = { "Status": "Rejected! Task rejected by ${var.email}" };
# #   } else {
# #     console.error("Unrecognized action. Expected: approve, reject.");
# #     callback({"Status": "Failed to process the request. Unrecognized Action."});
# #   }

# #   stepfunctions.sendTaskSuccess({
# #     output: JSON.stringify(message),
# #     taskToken: event.query.taskToken
# #   })
# #   .then(function(data) {
# #     redirectToStepFunctions(context.invokedFunctionArn, statemachineName, executionName, callback);
# #   }).catch(function(err) {
# #     console.error(err, err.stack);
# #     callback(err);
# #   });
# # }
# # "
# #   }
# #   description = "Lambda function that callback to AWS Step Functions"
# #   function_name = "LambdaApprovalFunction"
# #   handler = "index.handler"
# #   role = aws_iam_role.lambda_api_gateway_iam_role.arn
# #   runtime = "nodejs18.x"
# # }

# resource "aws_lambda_permission" "lambda_api_gateway_invoke" {
#   action = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.lambda_approval_function.arn
#   principal = "apigateway.amazonaws.com"
#   source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.execution_api.arn}/*"
# }

# resource "aws_iam_role" "lambda_api_gateway_iam_role" {
#   assume_role_policy = {
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "sts:AssumeRole"
#         ]
#         Effect = "Allow"
#         Principal = {
#           Service = [
#             "lambda.amazonaws.com"
#           ]
#         }
#       }
#     ]
#   }
#   force_detach_policies = [
#     {
#       PolicyName = "CloudWatchLogsPolicy"
#       PolicyDocument = {
#         Statement = [
#           {
#             Effect = "Allow"
#             Action = [
#               "logs:*"
#             ]
#             Resource = "arn:${data.aws_partition.current.partition}:logs:*:*:*"
#           }
#         ]
#       }
#     },
#     {
#       PolicyName = "StepFunctionsPolicy"
#       PolicyDocument = {
#         Statement = [
#           {
#             Effect = "Allow"
#             Action = [
#               "states:SendTaskFailure",
#               "states:SendTaskSuccess"
#             ]
#             Resource = "*"
#           }
#         ]
#       }
#     }
#   ]
# }
