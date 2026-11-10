/**
 * Run with: npx tsx scripts/create-admin.ts
 * Creates an admin user directly in MongoDB (no Firebase required).
 */
import { config } from "dotenv";
config();

const mongoose = (await import("mongoose")).default;
const { ENV } = await import("../src/config/env.js");
const { User } = await import("../src/modules/users/user.model.js");

const ADMIN_EMAIL = "admin@church.com";
const ADMIN_PASSWORD = "Admin@12345";
const ADMIN_USERNAME = "admin";
const ADMIN_PHONE = "0912345678";

console.log("Connecting to MongoDB...");
await mongoose.connect(ENV.MONGODB_URI);
console.log("MongoDB connected");

const existing = await User.findOne({ email: ADMIN_EMAIL }).select("+password");
if (existing) {
  existing.role = "admin";
  existing.is_admin = true;
  if (!existing.firebaseUid) existing.firebaseUid = "admin-direct";
  await existing.save();
  console.log("Existing user updated → role: admin, is_admin: true");
} else {
  await User.create({
    firebaseUid: "admin-direct",
    username: ADMIN_USERNAME,
    email: ADMIN_EMAIL,
    password: ADMIN_PASSWORD,
    phone_number: ADMIN_PHONE,
    role: "admin",
    is_admin: true,
  });
  console.log("Admin user created in MongoDB");
}

console.log("\n✅ Done! You can now log in:");
console.log(`   Email:    ${ADMIN_EMAIL}`);
console.log(`   Password: ${ADMIN_PASSWORD}`);
console.log(`   URL:      http://localhost:5173`);

await mongoose.disconnect();
process.exit(0);
