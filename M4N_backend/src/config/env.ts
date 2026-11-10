export const ENV = {
  PORT: process.env.PORT || 5000,
  MONGODB_URI:
    process.env.MONGODB_URI?.replace(
      "<db_password>",
      process.env.PASSWORD || "",
    ) || "",
  JWT_SECRET: process.env.JWT_SECRET || "secret-keying",
  JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || "7d",
  CHAPA_TEST_SECRET_KEY: process.env.CHAPA_TEST_SECRET_KEY || "",
  CHAPA_SECRET: process.env.CHAPA_SECRET || "",
};
