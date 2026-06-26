require("dotenv").config();
const express = require("express");
const cors = require("cors");
const bcrypt = require("bcryptjs");
const connectDB = require("./src/config/db");
const predictRoutes = require("./src/routes/predictRoutes");
const authRoutes = require("./src/routes/authRoutes");
const adminRoutes = require("./src/routes/adminRoutes");
const paymentRoutes = require("./src/routes/paymentRoutes");
const chatRoutes = require("./src/routes/chatRoutes");
const User = require("./src/models/User");

const app = express();

connectDB();

// Auto-create the default admin account if it doesn't exist.
// Change ADMIN_EMAIL / ADMIN_PASSWORD env vars to override.
const ensureAdmin = async () => {
  try {
    const email = process.env.ADMIN_EMAIL || "admin@anemia.com";
    const password = process.env.ADMIN_PASSWORD || "Admin@123";
    const existing = await User.findOne({ email });
    if (existing) {
      if (existing.role !== "admin") {
        existing.role = "admin";
        await existing.save();
        console.log(`[Admin] Upgraded ${email} to admin`);
      }
      return;
    }
    await User.create({
      name: "System Admin",
      email,
      password: await bcrypt.hash(password, 10),
      role: "admin",
    });
    console.log(`[Admin] Created default admin: ${email} / ${password}`);
  } catch (e) {
    console.error("[Admin] ensureAdmin failed:", e.message);
  }
};
ensureAdmin();

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.send("Node.js Backend Running");
});

app.use("/api/auth", authRoutes);
app.use("/api/predict", predictRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/payment", paymentRoutes);
app.use("/api/chat", chatRoutes);

app.listen(3000, () => {
  console.log("Server running on http://localhost:3000");
  console.log("Auth endpoints:");
  console.log("  POST /api/auth/register");
  console.log("  POST /api/auth/login");
  console.log("  POST /api/auth/forgot-password");
  console.log("  POST /api/auth/verify-otp");
  console.log("  POST /api/auth/reset-password");
  console.log("Admin endpoints (require admin token):");
  console.log("  GET    /api/admin/stats");
  console.log("  GET    /api/admin/users");
  console.log("  GET    /api/admin/users/:id");
  console.log("  DELETE /api/admin/users/:id");
  console.log("  POST   /api/admin/users/:id/reset-password");
  console.log("  DELETE /api/admin/assessments/:id");
  console.log("Payment endpoint:");
  console.log("  POST   /api/payment/charge");
  console.log("Chat endpoint:");
  console.log("  POST   /api/chat");
});
