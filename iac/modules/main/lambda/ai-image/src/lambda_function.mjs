console.log("Loading function");

export const handler = (event, context, callback) => {
  console.log(`event= ${JSON.stringify(event)}`);
};

export default handler;
