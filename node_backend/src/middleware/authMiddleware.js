const jwt = require("jsonwebtoken");

const JWT_SECRET = process.env.JWT_SECRET || "anemia_thesis_secret_2026";

/**
 * Optional auth: if a Bearer token is present and valid, attach req.userId.
 * If absent or invalid, just continue without userId (for guest support).
 */
const optionalAuth = (req, res, next) => {
  const header = req.headers.authorization || "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : null;

  if (!token) {
    req.userId = null;
    return next();
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.userId = decoded.id;
  } catch (e) {
    req.userId = null;
  }
  return next();
};

/**
 * Strict auth: requires a valid Bearer token. Returns 401 otherwise.
 * Used for endpoints that should ONLY be accessible to logged-in users
 * (e.g. assessment history).
 */
const requireAuth = (req, res, next) => {
  const header = req.headers.authorization || "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : null;

  if (!token) {
    return res.status(401).json({
      success: false,
      message: "Authentication required",
    });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.userId = decoded.id;
    req.userEmail = decoded.email;
    return next();
  } catch (e) {
    return res.status(401).json({
      success: false,
      message: "Invalid or expired token",
    });
  }
};

/**
 * Admin-only: requires a valid token AND the user's role to be "admin".
 * Role is checked against the database (not just the token) so revoking
 * admin takes effect immediately.
 */
const requireAdmin = async (req, res, next) => {
  const header = req.headers.authorization || "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : null;

  if (!token) {
    return res.status(401).json({
      success: false,
      message: "Authentication required",
    });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    const User = require("../models/User");
    const user = await User.findById(decoded.id).select("role email");
    if (!user || user.role !== "admin") {
      return res.status(403).json({
        success: false,
        message: "Admin access required",
      });
    }
    req.userId = decoded.id;
    req.userEmail = user.email;
    return next();
  } catch (e) {
    return res.status(401).json({
      success: false,
      message: "Invalid or expired token",
    });
  }
};

module.exports = { optionalAuth, requireAuth, requireAdmin };
