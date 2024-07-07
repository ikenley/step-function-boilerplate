export const handler = async (event, context, callback) => {
  callback(null, "Hello from " + event.who + "!");
};
