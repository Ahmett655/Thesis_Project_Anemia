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

module.exports = { optionalAuth, requireAuth };
