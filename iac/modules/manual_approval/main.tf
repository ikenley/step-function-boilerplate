// Cloning Terraform src code to /tmp/terraform_src...
// code has been checked out.

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

variable email {
  type = string
}

resource "aws_api_gateway_rest_api" "execution_api" {
  name = "Human approval endpoint"
  description = "HTTP Endpoint backed by API Gateway and Lambda"
  fail_on_warnings = true
}

resource "aws_api_gateway_resource" "execution_resource" {
  rest_api_id = aws_api_gateway_rest_api.execution_api.arn
  parent_id = aws_api_gateway_rest_api.execution_api.root_resource_id
  path_part = "execution"
}

resource "aws_api_gateway_method" "execution_method" {
  authorization = "NONE"
  http_method = "GET"
  // CF Property(Integration) = {
  //   Type = "AWS"
  //   IntegrationHttpMethod = "POST"
  //   Uri = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda_approval_function.arn}/invocations"
  //   IntegrationResponses = [
  //     {
  //       StatusCode = 302
  //       ResponseParameters = {
  //         method.response.header.Location = "integration.response.body.headers.Location"
  //       }
  //     }
  //   ]
  //   RequestTemplates = {
  //     application/json = "{
  //   "body" : $input.json('$'),
  //   "headers": {
  //     #foreach($header in $input.params().header.keySet())
  //     "$header": "$util.escapeJavaScript($input.params().header.get($header))" #if($foreach.hasNext),#end
  // 
  //     #end
  //   },
  //   "method": "$context.httpMethod",
  //   "params": {
  //     #foreach($param in $input.params().path.keySet())
  //     "$param": "$util.escapeJavaScript($input.params().path.get($param))" #if($foreach.hasNext),#end
  // 
  //     #end
  //   },
  //   "query": {
  //     #foreach($queryParam in $input.params().querystring.keySet())
  //     "$queryParam": "$util.escapeJavaScript($input.params().querystring.get($queryParam))" #if($foreach.hasNext),#end
  // 
  //     #end
  //   }  
  // }
  // "
  //   }
  // }
  resource_id = aws_api_gateway_resource.execution_resource.id
  rest_api_id = aws_api_gateway_rest_api.execution_api.arn
  // CF Property(MethodResponses) = [
  //   {
  //     StatusCode = 302
  //     ResponseParameters = {
  //       method.response.header.Location = true
  //     }
  //   }
  // ]
}

resource "aws_api_gateway_account" "api_gateway_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloud_watch_logs_role.arn
}

resource "aws_iam_role" "api_gateway_cloud_watch_logs_role" {
  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "apigateway.amazonaws.com"
          ]
        }
        Action = [
          "sts:AssumeRole"
        ]
      }
    ]
  }
  force_detach_policies = [
    {
      PolicyName = "ApiGatewayLogsPolicy"
      PolicyDocument = {
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "logs:*"
            ]
            Resource = "arn:${data.aws_partition.current.partition}:logs:*:*:*"
          }
        ]
      }
    }
  ]
}

resource "aws_api_gateway_stage" "execution_api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  // CF Property(MethodSettings) = [
  //   {
  //     DataTraceEnabled = true
  //     HttpMethod = "*"
  //     LoggingLevel = "INFO"
  //     ResourcePath = "/*"
  //   }
  // ]
  rest_api_id = aws_api_gateway_rest_api.execution_api.arn
  stage_name = "states"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.execution_api.arn
  stage_name = "DummyStage"
}

# resource "aws_lambda_function" "lambda_approval_function" {
#   code_signing_config_arn = {
#     ZipFile = "const { SFN: StepFunctions } = require("@aws-sdk/client-sfn");
# var redirectToStepFunctions = function(lambdaArn, statemachineName, executionName, callback) {
#   const lambdaArnTokens = lambdaArn.split(":");
#   const partition = lambdaArnTokens[1];
#   const region = lambdaArnTokens[3];
#   const accountId = lambdaArnTokens[4];

#   console.log("partition=" + partition);
#   console.log("region=" + region);
#   console.log("accountId=" + accountId);

#   const executionArn = "arn:" + partition + ":states:" + region + ":" + accountId + ":execution:" + statemachineName + ":" + executionName;
#   console.log("executionArn=" + executionArn);

#   const url = "https://console.aws.amazon.com/states/home?region=" + region + "#/executions/details/" + executionArn;
#   callback(null, {
#       statusCode: 302,
#       headers: {
#         Location: url
#       }
#   });
# };

# exports.handler = (event, context, callback) => {
#   console.log('Event= ' + JSON.stringify(event));
#   const action = event.query.action;
#   const taskToken = event.query.taskToken;
#   const statemachineName = event.query.sm;
#   const executionName = event.query.ex;

#   const stepfunctions = new StepFunctions();

#   var message = "";

#   if (action === "approve") {
#     message = { "Status": "Approved! Task approved by ${var.email}" };
#   } else if (action === "reject") {
#     message = { "Status": "Rejected! Task rejected by ${var.email}" };
#   } else {
#     console.error("Unrecognized action. Expected: approve, reject.");
#     callback({"Status": "Failed to process the request. Unrecognized Action."});
#   }

#   stepfunctions.sendTaskSuccess({
#     output: JSON.stringify(message),
#     taskToken: event.query.taskToken
#   })
#   .then(function(data) {
#     redirectToStepFunctions(context.invokedFunctionArn, statemachineName, executionName, callback);
#   }).catch(function(err) {
#     console.error(err, err.stack);
#     callback(err);
#   });
# }
# "
#   }
#   description = "Lambda function that callback to AWS Step Functions"
#   function_name = "LambdaApprovalFunction"
#   handler = "index.handler"
#   role = aws_iam_role.lambda_api_gateway_iam_role.arn
#   runtime = "nodejs18.x"
# }

resource "aws_lambda_permission" "lambda_api_gateway_invoke" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_approval_function.arn
  principal = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.execution_api.arn}/*"
}

resource "aws_iam_role" "lambda_api_gateway_iam_role" {
  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole"
        ]
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com"
          ]
        }
      }
    ]
  }
  force_detach_policies = [
    {
      PolicyName = "CloudWatchLogsPolicy"
      PolicyDocument = {
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "logs:*"
            ]
            Resource = "arn:${data.aws_partition.current.partition}:logs:*:*:*"
          }
        ]
      }
    },
    {
      PolicyName = "StepFunctionsPolicy"
      PolicyDocument = {
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "states:SendTaskFailure",
              "states:SendTaskSuccess"
            ]
            Resource = "*"
          }
        ]
      }
    }
  ]
}

# resource "aws_sfn_state_machine" "human_approval_lambda_state_machine" {
#   role_arn = aws_iam_role.lambda_state_machine_execution_role.arn
#   definition = "{
#     "StartAt": "Lambda Callback",
#     "TimeoutSeconds": 3600,
#     "States": {
#         "Lambda Callback": {
#             "Type": "Task",
#             "Resource": "arn:${data.aws_partition.current.partition}:states:::lambda:invoke.waitForTaskToken",
#             "Parameters": {
#               "FunctionName": "${aws_lambda_function.lambda_human_approval_send_email_function.arn}",
#               "Payload": {
#                 "ExecutionContext.$": "$$",
#                 "APIGatewayEndpoint": "https://${aws_api_gateway_rest_api.execution_api.arn}.execute-api.${data.aws_region.current.name}.amazonaws.com/states"
#               }
#             },
#             "Next": "ManualApprovalChoiceState"
#         },
#         "ManualApprovalChoiceState": {
#           "Type": "Choice",
#           "Choices": [
#             {
#               "Variable": "$.Status",
#               "StringEquals": "Approved! Task approved by ${var.email}",
#               "Next": "ApprovedPassState"
#             },
#             {
#               "Variable": "$.Status",
#               "StringEquals": "Rejected! Task rejected by ${var.email}",
#               "Next": "RejectedPassState"
#             }
#           ]
#         },
#         "ApprovedPassState": {
#           "Type": "Pass",
#           "End": true
#         },
#         "RejectedPassState": {
#           "Type": "Pass",
#           "End": true
#         }
#     }
# }
# "
# }

resource "aws_sns_topic" "sns_human_approval_email_topic" {
  // CF Property(Subscription) = [
  //   {
  //     Endpoint = "${var.email}"
  //     Protocol = "email"
  //   }
  // ]
}

# resource "aws_lambda_function" "lambda_human_approval_send_email_function" {
#   handler = "index.lambda_handler"
#   role = aws_iam_role.lambda_send_email_execution_role.arn
#   runtime = "nodejs18.x"
#   timeout = "25"
#   code_signing_config_arn = {
#     ZipFile = "console.log('Loading function');
# const { SNS } = require("@aws-sdk/client-sns");
# exports.lambda_handler = (event, context, callback) => {
#     console.log('event= ' + JSON.stringify(event));
#     console.log('context= ' + JSON.stringify(context));

#     const executionContext = event.ExecutionContext;
#     console.log('executionContext= ' + executionContext);

#     const executionName = executionContext.Execution.Name;
#     console.log('executionName= ' + executionName);

#     const statemachineName = executionContext.StateMachine.Name;
#     console.log('statemachineName= ' + statemachineName);

#     const taskToken = executionContext.Task.Token;
#     console.log('taskToken= ' + taskToken);

#     const apigwEndpint = event.APIGatewayEndpoint;
#     console.log('apigwEndpint = ' + apigwEndpint)

#     const approveEndpoint = apigwEndpint + "/execution?action=approve&ex=" + executionName + "&sm=" + statemachineName + "&taskToken=" + encodeURIComponent(taskToken);
#     console.log('approveEndpoint= ' + approveEndpoint);

#     const rejectEndpoint = apigwEndpint + "/execution?action=reject&ex=" + executionName + "&sm=" + statemachineName + "&taskToken=" + encodeURIComponent(taskToken);
#     console.log('rejectEndpoint= ' + rejectEndpoint);

#     const emailSnsTopic = "${aws_sns_topic.sns_human_approval_email_topic.id}";
#     console.log('emailSnsTopic= ' + emailSnsTopic);

#     var emailMessage = 'Welcome! \n\n';
#     emailMessage += 'This is an email requiring an approval for a step functions execution. \n\n'
#     emailMessage += 'Please check the following information and click "Approve" link if you want to approve. \n\n'
#     emailMessage += 'Execution Name -> ' + executionName + '\n\n'
#     emailMessage += 'Approve ' + approveEndpoint + '\n\n'
#     emailMessage += 'Reject ' + rejectEndpoint + '\n\n'
#     emailMessage += 'Thanks for using Step functions!'
    
#     const sns = new SNS();
#     var params = {
#       Message: emailMessage,
#       Subject: "Required approval from AWS Step Functions",
#       TopicArn: emailSnsTopic
#     };

#     sns.publish(params)
#       .then(function(data) {
#         console.log("MessageID is " + data.MessageId);
#         callback(null);
#       }).catch(
#         function(err) {
#         console.error(err, err.stack);
#         callback(err);
#       });
# }
# "
#   }
# }

resource "aws_iam_role" "lambda_state_machine_execution_role" {
  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  }
  force_detach_policies = [
    {
      PolicyName = "InvokeCallbackLambda"
      PolicyDocument = {
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "lambda:InvokeFunction"
            ]
            Resource = [
              "${aws_lambda_function.lambda_human_approval_send_email_function.arn}"
            ]
          }
        ]
      }
    }
  ]
}

resource "aws_iam_role" "lambda_send_email_execution_role" {
  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  }
  force_detach_policies = [
    {
      PolicyName = "CloudWatchLogsPolicy"
      PolicyDocument = {
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
            ]
            Resource = "arn:${data.aws_partition.current.partition}:logs:*:*:*"
          }
        ]
      }
    },
    {
      PolicyName = "SNSSendEmailPolicy"
      PolicyDocument = {
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "SNS:Publish"
            ]
            Resource = [
              "${aws_sns_topic.sns_human_approval_email_topic.id}"
            ]
          }
        ]
      }
    }
  ]
}

output "api_gateway_invoke_url" {
  value = "https://${aws_api_gateway_rest_api.execution_api.arn}.execute-api.${data.aws_region.current.name}.amazonaws.com/states"
}

output "state_machine_human_approval_arn" {
  value = aws_sfn_state_machine.human_approval_lambda_state_machine.id
}
