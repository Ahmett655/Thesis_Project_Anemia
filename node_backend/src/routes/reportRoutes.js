const express = require("express");
const router = express.Router();
const { getReport } = require("../controllers/reportController");
const { requireAdmin } = require("../middleware/authMiddleware");

// Reports are an admin-only view of system activity.
router.use(requireAdmin);

// GET /api/reports?period=daily|weekly|monthly
router.get("/", getReport);

module.exports = router;
