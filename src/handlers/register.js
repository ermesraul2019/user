const { CognitoIdentityProviderClient, SignUpCommand } = require("@aws-sdk/client-cognito-identity-provider");
const { SQSClient, SendMessageCommand } = require("@aws-sdk/client-sqs");
const AWS = require("aws-sdk");
const uuid = require("uuid");
const dynamodb = new AWS.DynamoDB.DocumentClient();

const client = new CognitoIdentityProviderClient({ region: "us-east-1" }); // Cambia la región si aplica
const sqs = new SQSClient({ region: process.env.AWS_REGION || "us-west-1" }); // Usa la región de tu cola

const USERS_TABLE = process.env.USERS_TABLE;
const SQS_URL = process.env.SQS_URL; // URL de la cola SQS

const createUser = async (data) => {
	const newUser = {
		id: uuid.v4(),
		name: data.name,
		email: data.email,
		phone: data.phone,
		createdAt: new Date().toISOString()
	};

	const params = {
		TableName: USERS_TABLE,
		Item: newUser,
		ConditionExpression: "attribute_not_exists(email)"
	};

	try {
		await dynamodb.put(params).promise();
		return { ok: true, newUser };
	} catch (err) {
		if (err.code === "ConditionalCheckFailedException") {
			return { ok: false, error: "El email ya está registrado" };
		}
		return { ok: false, error: "Error al registrar usuario", error: err.message };
	}
};

exports.handler = async (event) => {
	const body = JSON.parse(event.body);
	const { email, password, phone, name } = body;

	if (!name || !email || !password || !phone) {
		return {
			statusCode: 400,
			body: JSON.stringify({ message: "Todos los campos son obligatorios" })
		};
	}

	try {
		const command = new SignUpCommand({
			ClientId: process.env.USER_CLIENT_ID,
			Username: email,
			Password: password,
			UserAttributes: [
				{ Name: "email", Value: String(email) },
				{ Name: "phone_number", Value: String(phone) }
			]
		});

		const result = await client.send(command);

		const userData = await createUser(body);

		if (!userData.ok) {
			return {
				statusCode: 400,
				body: JSON.stringify({ message: userData.error })
			};
		}

		// PRODUCER SQS: envía mensaje para crear tarjeta DEBIT
		const sqsMsg = {
			userId: userData.newUser.id,
			request: "DEBIT"
		};
		await sqs.send(new SendMessageCommand({
			QueueUrl: SQS_URL,
			MessageBody: JSON.stringify(sqsMsg)
		}));

		// PRODUCER SQS: envía mensaje para crear tarjeta CREDIT
		const sqsMsgCredit = {
			userId: userData.newUser.id,
			request: "CREDIT"
		};
		await sqs.send(new SendMessageCommand({
			QueueUrl: SQS_URL,
			MessageBody: JSON.stringify(sqsMsgCredit)
		}));

		return {
			statusCode: 201,
			body: JSON.stringify({ message: "Usuario registrado", userSub: result.UserSub })
		};
	} catch (error) {
		return {
			statusCode: 400,
			body: JSON.stringify({ message: "Error al registrar usuario", error: error.toString() })
		};
	}
};