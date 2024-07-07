export const handler = async (event, context, callback) => {
  const result = { message: `Hello from ${event.who} !` };
  callback(null, result);
};
