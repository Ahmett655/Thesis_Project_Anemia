const express = require("express");
const router = express.Router();
const { chat } = require("../controllers/chatController");
const { optionalAuth } = require("../middleware/authMiddleware");

// POST /api/chat — anemia Q&A assistant (works for guests + logged-in users).
router.post("/", optionalAuth, chat);

module.exports = router;
