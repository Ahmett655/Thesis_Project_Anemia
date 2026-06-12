const express = require("express");
const router = express.Router();
const {
  getStats,
  listUsers,
  getUserDetail,
  deleteUser,
  listAssessments,
  deleteAssessment,
  resetUserPassword,
} = require("../controllers/adminController");
const { requireAdmin } = require("../middleware/authMiddleware");

// Everything under /api/admin requires an admin account.
router.use(requireAdmin);

router.get("/stats", getStats);
router.get("/users", listUsers);
router.get("/users/:id", getUserDetail);
router.delete("/users/:id", deleteUser);
router.post("/users/:id/reset-password", resetUserPassword);
router.get("/assessments", listAssessments);
router.delete("/assessments/:id", deleteAssessment);

module.exports = router;
