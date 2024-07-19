import { randomUUID } from "crypto";
import { parseArgs } from "node:util";
import { BedrockRuntimeClient } from "@aws-sdk/client-bedrock-runtime";
import { S3Client } from "@aws-sdk/client-s3";
import { getConfigOptions } from "./config/ConfigOptions.mjs";
import ImageGeneratorService from "./ai/ImageGeneratorService.mjs";

const main = async () => {
  const args = getArguments();
  console.log("args", JSON.stringify(args));
  const imageId = args.id;
  const prompt = args.prompt;

  const config = getConfigOptions();

  const bedrockClient = new BedrockRuntimeClient();

  const s3Client = new S3Client();

  const imageGeneratorService = new ImageGeneratorService(
    config,
    bedrockClient,
    s3Client
  );

  await imageGeneratorService.generate(imageId, prompt);
};

/** Parse CLI arguments.
 * This could be a library like yargs or commander, but for now we'll avoid dependencies.
 */
const getArguments = () => {
  const args = process.args;
  const options = {
    id: {
      type: "string",
      short: "i",
    },
    prompt: {
      type: "string",
      short: "p",
    },
  };

  const { values, positionals } = parseArgs({
    args,
    options,
    allowPositionals: true,
  });

  // Basic validation
  if (!values.id) {
    values.id = randomUUID();
  }
  if (!values.prompt) {
    throw new Error("--prompt argument is required.");
  }

  return { command: positionals[0], ...values };
};

main();
