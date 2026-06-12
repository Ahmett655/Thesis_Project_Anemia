const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/User");

const JWT_SECRET = process.env.JWT_SECRET || "anemia_thesis_secret_2026";
const JWT_EXPIRES_IN = "7d";

// ============================================================
// REGISTER — POST /api/auth/register
// ============================================================
const register = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    // Validation
    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: "Name, email, and password are required",
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: "Password must be at least 6 characters",
      });
    }

    // Check if user already exists
    const existing = await User.findOne({ email: email.toLowerCase() });
    if (existing) {
      return res.status(409).json({
        success: false,
        message: "Email already registered",
      });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    const user = await User.create({
      name: name.trim(),
      email: email.toLowerCase().trim(),
      password: hashedPassword,
    });

    // Generate JWT token
    const token = jwt.sign(
      { id: user._id, email: user.email },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );

    console.log(`[Auth] Registered: ${user.email}`);

    return res.status(201).json({
      success: true,
      message: "Registration successful",
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    console.error("[Auth] Register error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Registration failed",
      error: error.message,
    });
  }
};

// ============================================================
// LOGIN — POST /api/auth/login
// ============================================================
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email and password are required",
      });
    }

    // Find user
    const user = await User.findOne({ email: email.toLowerCase().trim() });
    if (!user) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password",
      });
    }

    // Verify password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password",
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      { id: user._id, email: user.email },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );

    console.log(`[Auth] Login: ${user.email}`);

    return res.status(200).json({
      success: true,
      message: "Login successful",
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    console.error("[Auth] Login error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Login failed",
      error: error.message,
    });
  }
};

// ============================================================
// FORGOT PASSWORD — POST /api/auth/forgot-password
// Generates 4-digit OTP and stores it (would email in production)
// ============================================================
const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: "Email is required",
      });
    }

    const user = await User.findOne({ email: email.toLowerCase().trim() });
    if (!user) {
      return res.status(404).json({
        success: false,
        message: "No account found with this email",
      });
    }

    // Generate 4-digit OTP
    const otp = Math.floor(1000 + Math.random() * 9000).toString();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    user.resetOtp = otp;
    user.resetOtpExpires = otpExpires;
    await user.save();

    console.log(`[Auth] OTP for ${user.email}: ${otp} (expires in 10 min)`);

    // NOTE: In production, send OTP via email (SendGrid / Nodemailer / etc.)
    // For development/thesis demo, we return the OTP in the response.
    return res.status(200).json({
      success: true,
      message: "OTP sent successfully",
      // Demo only — in production, do NOT return the OTP:
      otp: otp,
      expiresIn: "10 minutes",
    });
  } catch (error) {
    console.error("[Auth] Forgot password error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Failed to send OTP",
      error: error.message,
    });
  }
};

// ============================================================
// VERIFY OTP — POST /api/auth/verify-otp
// ============================================================
const verifyOtp = async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({
        success: false,
        message: "Email and OTP are required",
      });
    }

    const user = await User.findOne({ email: email.toLowerCase().trim() });
    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    if (!user.resetOtp || user.resetOtp !== otp.toString()) {
      return res.status(401).json({
        success: false,
        message: "Invalid OTP",
      });
    }

    if (user.resetOtpExpires && user.resetOtpExpires < new Date()) {
      return res.status(401).json({
        success: false,
        message: "OTP has expired. Please request a new one.",
      });
    }

    // OTP valid — issue a short-lived reset token
    const resetToken = jwt.sign(
      { id: user._id, purpose: "password_reset" },
      JWT_SECRET,
      { expiresIn: "15m" }
    );

    console.log(`[Auth] OTP verified for ${user.email}`);

    return res.status(200).json({
      success: true,
      message: "OTP verified successfully",
      resetToken,
    });
  } catch (error) {
    console.error("[Auth] Verify OTP error:", error.message);
    return res.status(500).json({
      success: false,
      message: "OTP verification failed",
      error: error.message,
    });
  }
};

// ============================================================
// RESET PASSWORD — POST /api/auth/reset-password
// ============================================================
const resetPassword = async (req, res) => {
  try {
    const { email, otp, newPassword } = req.body;

    if (!email || !otp || !newPassword) {
      return res.status(400).json({
        success: false,
        message: "Email, OTP, and new password are required",
      });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        message: "Password must be at least 6 characters",
      });
    }

    const user = await User.findOne({ email: email.toLowerCase().trim() });
    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    if (!user.resetOtp || user.resetOtp !== otp.toString()) {
      return res.status(401).json({
        success: false,
        message: "Invalid OTP",
      });
    }

    if (user.resetOtpExpires && user.resetOtpExpires < new Date()) {
      return res.status(401).json({
        success: false,
        message: "OTP has expired. Please request a new one.",
      });
    }

    // Hash new password
    user.password = await bcrypt.hash(newPassword, 10);
    // Clear OTP fields
    user.resetOtp = null;
    user.resetOtpExpires = null;
    await user.save();

    console.log(`[Auth] Password reset for ${user.email}`);

    return res.status(200).json({
      success: true,
      message: "Password reset successfully. You can now login.",
    });
  } catch (error) {
    console.error("[Auth] Reset password error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Password reset failed",
      error: error.message,
    });
  }
};

module.exports = {
  register,
  login,
  forgotPassword,
  verifyOtp,
  resetPassword,
};
