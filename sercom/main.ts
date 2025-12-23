import { Sercom } from "./src/Sercom.ts";

// Read password from environment variables (required, no fallback)
const password = process.env.SERCOM_PASSWORD;
if (!password) {
  throw new Error("SERCOM_PASSWORD environment variable is required. Please set it in .env file.");
}

const sercom = await Sercom.login("vodafone", password);
const lanSettings = await sercom.getLanSettings();

console.log("LAN Settings Response:", JSON.stringify(lanSettings, null, 2));
