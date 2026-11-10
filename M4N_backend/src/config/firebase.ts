import admin from "firebase-admin";
import type { ServiceAccount } from "firebase-admin";
import path from "path";
import { fileURLToPath } from "url";
import { readFileSync, existsSync } from "fs";
import stripJsonComments from "strip-json-comments";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

let serviceAccount: ServiceAccount | null = null;
const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;

if (serviceAccountJson) {
  try {
    serviceAccount = JSON.parse(serviceAccountJson) as ServiceAccount;
  } catch (error) {
    throw new Error(
      "Invalid FIREBASE_SERVICE_ACCOUNT_JSON. Ensure it is valid JSON.",
    );
  }
} else {
  const serviceAccountPath = path.join(
    __dirname,
    "../../serviceAccountKey.json",
  );
  if (existsSync(serviceAccountPath)) {
    const raw = readFileSync(serviceAccountPath, "utf8").replace(/^\uFEFF/, "");
    try {
      serviceAccount = JSON.parse(raw) as ServiceAccount;
    } catch {
      serviceAccount = JSON.parse(stripJsonComments(raw)) as ServiceAccount;
    }
  } else {
    console.warn(
      "WARNING: No Firebase credentials found. Set FIREBASE_SERVICE_ACCOUNT_JSON env var or provide serviceAccountKey.json",
    );
  }
}

if (serviceAccount) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
} else {
  admin.initializeApp();
}

export default admin;
