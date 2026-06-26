const express = require("express");
const router = express.Router();
const {
  register,
  login,
  forgotPassword,
  verifyOtp,
  resetPassword,
  googleSignIn,
} = require("../controllers/authController");

// POST /api/auth/register
router.post("/register", register);

// POST /api/auth/login
router.post("/login", login);

// POST /api/auth/forgot-password
router.post("/forgot-password", forgotPassword);

// POST /api/auth/verify-otp
router.post("/verify-otp", verifyOtp);

// POST /api/auth/reset-password
router.post("/reset-password", resetPassword);

// POST /api/auth/google — sign in / register with a Google ID token
router.post("/google", googleSignIn);

module.exports = router;
