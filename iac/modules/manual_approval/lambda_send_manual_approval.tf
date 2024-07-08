#-------------------------------------------------------------------------------
# Function which sends the mamnual approval email
#-------------------------------------------------------------------------------

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