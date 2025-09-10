const { CognitoIdentityProviderClient, ConfirmSignUpCommand } = require("@aws-sdk/client-cognito-identity-provider");

// Cliente de Cognito (puede usarse también desde un helper en /opt/auth)
const client = new CognitoIdentityProviderClient({ region: "us-east-1" });

exports.handler = async (event) => {
  const { email, code } = JSON.parse(event.body || "{}");

  if (!email || !code) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: "Email y código de confirmación son obligatorios" })
    };
  }

  try {
    await client.send(
      new ConfirmSignUpCommand({
        ClientId: process.env.USER_CLIENT_ID,
        Username: email,
        ConfirmationCode: code
      })
    );

    return {
      statusCode: 200,
      body: JSON.stringify({ message: "Usuario confirmado exitosamente" })
    };
  } catch (error) {
    return {
      statusCode: 400,
      body: JSON.stringify({
        message: "Error al confirmar usuario",
        error: error.message || error.toString()
      })
    };
  }
};
