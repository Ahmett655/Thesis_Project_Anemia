const express = require("express");
const router = express.Router();
const { predictAnemia, getHistory } = require("../controllers/predictController");
const { optionalAuth, requireAuth } = require("../middleware/authMiddleware");

// POST /api/predict — optional auth (works for guests + logged-in users)
router.post("/", optionalAuth, predictAnemia);

// GET /api/predict/history — REQUIRES auth (logged-in users only)
router.get("/history", requireAuth, getHistory);

module.exports = router;
