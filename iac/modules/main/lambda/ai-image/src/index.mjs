import { randomUUID } from "crypto";
import { BedrockRuntimeClient } from "@aws-sdk/client-bedrock-runtime";
import { S3Client } from "@aws-sdk/client-s3";
import { getConfigOptions } from "./config/ConfigOptions.mjs";
import ImageGeneratorService from "./ai/ImageGeneratorService.mjs";

const main = async () => {
  const config = getConfigOptions();

  const bedrockClient = new BedrockRuntimeClient();

  const s3Client = new S3Client();

  const imageGeneratorService = new ImageGeneratorService(
    config,
    bedrockClient,
    s3Client
  );

  const imageId = randomUUID();
  const prompt = "A man typing on a laptop on a pier";

  await imageGeneratorService.generate(imageId, prompt);
};

main();
