const express = require("express");
const router = express.Router();
const { createBooking, getBookings } = require("../controllers/bookingController");
const { optionalAuth, requireAuth } = require("../middleware/authMiddleware");

// POST /api/booking — create a booking (guests + logged-in users)
router.post("/", optionalAuth, createBooking);

// GET /api/booking/history — logged-in users only
router.get("/history", requireAuth, getBookings);

module.exports = router;
