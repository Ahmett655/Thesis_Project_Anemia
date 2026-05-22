const express = require("express");
const cors = require("cors");
const connectDB = require("./src/config/db");
const predictRoutes = require("./src/routes/predictRoutes");
const authRoutes = require("./src/routes/authRoutes");

const app = express();

connectDB();

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.send("Node.js Backend Running");
});

app.use("/api/auth", authRoutes);
app.use("/api/predict", predictRoutes);

app.listen(3000, () => {
  console.log("Server running on http://localhost:3000");
  console.log("Auth endpoints:");
  console.log("  POST /api/auth/register");
  console.log("  POST /api/auth/login");
  console.log("  POST /api/auth/forgot-password");
  console.log("  POST /api/auth/verify-otp");
  console.log("  POST /api/auth/reset-password");
});