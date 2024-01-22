const { Kafka } = require("kafkajs");
const AWS = require("aws-sdk");
require("dotenv").config();

AWS.config.update({ region: "eu-central-1" });

const secretsManager = new AWS.SecretsManager();

console.log("STRING", process.env.BOOTSTRAP_BROKER_STRING);

const brokers = process.env.BOOTSTRAP_BROKER_STRING.split(",");

console.log("BROKERS", brokers);

// Retrieve the secret value from AWS Secrets Manager
const getSecret = async (secretName) => {
  return new Promise((resolve, reject) => {
    secretsManager.getSecretValue({ SecretId: secretName }, (err, data) => {
      if (err) {
        reject(err);
      } else {
        if ("SecretString" in data) {
          resolve(JSON.parse(data.SecretString));
        } else {
          let buff = new Buffer(data.SecretBinary, "base64");
          resolve(JSON.parse(buff.toString("ascii")));
        }
      }
    });
  });
};

const publishToKafka = async () => {
  const secret = await getSecret(process.env.SECRET_NAME);

  // Create a Kafka client
  const kafka = new Kafka({
    clientId: "my-app",
    brokers,
    ssl: true,
    sasl: {
      mechanism: "scram-sha-256",
      username: secret.username,
      password: secret.password,
    },
  });

  const producer = kafka.producer();

  // Connect to the Kafka broker
  await producer.connect();

  const data = require("./ecommerce_data.json");

  // Loop through the data and send each record as a message
  for (const record of data) {
    await producer.send({
      topic: "sample-topic",
      messages: [{ value: JSON.stringify(record) }],
    });
  }

  // Disconnect from the Kafka broker
  await producer.disconnect();
};

// Call the main function to publish records to Kafka
publishToKafka().catch(console.error);
