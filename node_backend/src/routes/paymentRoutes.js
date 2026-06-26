const express = require("express");
const router = express.Router();
const { charge } = require("../controllers/paymentController");
const { optionalAuth } = require("../middleware/authMiddleware");

// POST /api/payment/charge — works for guests and logged-in users.
router.post("/charge", optionalAuth, charge);

module.exports = router;
