import { randomUUID } from "crypto";

export const handler = async (event, context, callback) => {
  console.log(`event= ${JSON.stringify(event)}`);

  let result = {};
  if (event.command === "GetMetadata") {
    result = getMetadata();
  }

  console.log(`result= ${JSON.stringify(result)}`);

  callback(null, result);
};

/** Creates imageId and other metadata */
export const getMetadata = () => {
  return { imageId: randomUUID() };
};

export default handler;
