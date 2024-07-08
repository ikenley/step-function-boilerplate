#-------------------------------------------------------------------------------
# API gateway which accepts approve/reject requests
#-------------------------------------------------------------------------------

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
