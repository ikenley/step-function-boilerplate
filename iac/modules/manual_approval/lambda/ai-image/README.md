# ai-image

This is an example of a more complex Step Function use case. There are simplifications that one would not use in production, but it demonstrates a Step Function which uses:
- Lambda Functions
- An ECS Task
- A manual approval stage
- SNS notifications

A "real" application would presumably have tests, TypeScript, 3rd party dependencies, and better documentation. But boy is the Max Power way faster.

## Directory Structure

- src
    - lambda_function.mjs: The entrypoint for the Lambda function. This function will be called multiple times and will "route" to the correct actions.
    - index.mjs: The entrypoint for local development and Docker containers.
    - ai.js: The core application logic which all entrypoints share. If we were creating tests, this would make unit testing easier.