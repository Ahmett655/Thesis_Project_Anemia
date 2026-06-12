const bcrypt = require("bcryptjs");
const mongoose = require("mongoose");
const User = require("../models/User");
const Result = require("../models/Result");

// ============================================================
// SYSTEM STATS — GET /api/admin/stats
// Totals + risk/category breakdowns for the admin dashboard.
// ============================================================
const getStats = async (req, res) => {
  try {
    const [totalUsers, totalResults, byRisk, byCategory, recent] =
      await Promise.all([
        User.countDocuments({ role: { $ne: "admin" } }),
        Result.countDocuments(),
        Result.aggregate([
          { $group: { _id: "$prediction_number", count: { $sum: 1 } } },
        ]),
        Result.aggregate([
          { $group: { _id: "$category", count: { $sum: 1 } } },
        ]),
        Result.find()
          .sort({ createdAt: -1 })
          .limit(7)
          .select("prediction_number prediction_label category createdAt"),
      ]);

    const risk = { mild: 0, moderate: 0, severe: 0 };
    byRisk.forEach((r) => {
      if (r._id === 0) risk.mild = r.count;
      if (r._id === 1) risk.moderate = r.count;
      if (r._id === 2) risk.severe = r.count;
    });

    const category = { men: 0, women: 0, children: 0 };
    byCategory.forEach((c) => {
      if (category[c._id] !== undefined) category[c._id] = c.count;
    });

    const guestResults = await Result.countDocuments({ userId: null });

    return res.json({
      success: true,
      stats: {
        totalUsers,
        totalResults,
        guestResults,
        risk,
        category,
        recent,
      },
    });
  } catch (error) {
    console.error("[Admin] Stats error:", error.message);
    return res
      .status(500)
      .json({ success: false, message: "Failed to load stats" });
  }
};

// ============================================================
// LIST USERS — GET /api/admin/users
// All users with their assessment counts.
// ============================================================
const listUsers = async (req, res) => {
  try {
    const users = await User.find()
      .select("name email role createdAt")
      .sort({ createdAt: -1 });

    const counts = await Result.aggregate([
      { $match: { userId: { $ne: null } } },
      { $group: { _id: "$userId", count: { $sum: 1 } } },
    ]);
    const countMap = {};
    counts.forEach((c) => (countMap[c._id.toString()] = c.count));

    return res.json({
      success: true,
      users: users.map((u) => ({
        id: u._id,
        name: u.name,
        email: u.email,
        role: u.role,
        createdAt: u.createdAt,
        assessmentCount: countMap[u._id.toString()] || 0,
      })),
    });
  } catch (error) {
    console.error("[Admin] List users error:", error.message);
    return res
      .status(500)
      .json({ success: false, message: "Failed to list users" });
  }
};

// ============================================================
// USER DETAIL — GET /api/admin/users/:id
// One user + all their assessments (their full report).
// ============================================================
const getUserDetail = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res
        .status(400)
        .json({ success: false, message: "Invalid user id" });
    }

    const user = await User.findById(id).select("name email role createdAt");
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    const assessments = await Result.find({ userId: id }).sort({
      createdAt: -1,
    });

    return res.json({
      success: true,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        createdAt: user.createdAt,
      },
      assessments: assessments.map((a) => ({
        id: a._id,
        category: a.category,
        prediction_number: a.prediction_number,
        prediction_label: a.prediction_label,
        confidence: a.confidence,
        method: a.method,
        hemoglobin_value: a.hemoglobin_value,
        answers: a.answers,
        createdAt: a.createdAt,
      })),
    });
  } catch (error) {
    console.error("[Admin] User detail error:", error.message);
    return res
      .status(500)
      .json({ success: false, message: "Failed to load user" });
  }
};

// ============================================================
// DELETE USER — DELETE /api/admin/users/:id
// Removes the user and all their assessments. Admins cannot be
// deleted (and you cannot delete yourself).
// ============================================================
const deleteUser = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res
        .status(400)
        .json({ success: false, message: "Invalid user id" });
    }

    const user = await User.findById(id);
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }
    if (user.role === "admin") {
      return res
        .status(403)
        .json({ success: false, message: "Cannot delete an admin account" });
    }

    await Result.deleteMany({ userId: id });
    await User.findByIdAndDelete(id);

    console.log(`[Admin] Deleted user ${user.email} (+ their assessments)`);
    return res.json({
      success: true,
      message: "User and their assessments deleted",
    });
  } catch (error) {
    console.error("[Admin] Delete user error:", error.message);
    return res
      .status(500)
      .json({ success: false, message: "Failed to delete user" });
  }
};

// ============================================================
// LIST ASSESSMENTS — GET /api/admin/assessments
// Optional filters: ?risk=0|1|2  ?guest=true
// Includes the owner's name/email when available.
// ============================================================
const listAssessments = async (req, res) => {
  try {
    const { risk, guest } = req.query;
    const filter = {};
    if (risk !== undefined && risk !== "") {
      filter.prediction_number = Number(risk);
    }
    if (guest === "true") {
      filter.userId = null;
    }

    const items = await Result.find(filter)
      .sort({ createdAt: -1 })
      .limit(500)
      .populate("userId", "name email");

    return res.json({
      success: true,
      assessments: items.map((a) => ({
        id: a._id,
        category: a.category,
        prediction_number: a.prediction_number,
        prediction_label: a.prediction_label,
        confidence: a.confidence,
        method: a.method,
        hemoglobin_value: a.hemoglobin_value,
        createdAt: a.createdAt,
        userName: a.userId ? a.userId.name : null,
        userEmail: a.userId ? a.userId.email : null,
      })),
    });
  } catch (error) {
    console.error("[Admin] List assessments error:", error.message);
    return res
      .status(500)
      .json({ success: false, message: "Failed to list assessments" });
  }
};

// ============================================================
// DELETE ASSESSMENT — DELETE /api/admin/assessments/:id
// ============================================================
const deleteAssessment = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res
        .status(400)
        .json({ success: false, message: "Invalid assessment id" });
    }
    const deleted = await Result.findByIdAndDelete(id);
    if (!deleted) {
      return res
        .status(404)
        .json({ success: false, message: "Assessment not found" });
    }
    console.log(`[Admin] Deleted assessment ${id}`);
    return res.json({ success: true, message: "Assessment deleted" });
  } catch (error) {
    console.error("[Admin] Delete assessment error:", error.message);
    return res
      .status(500)
      .json({ success: false, message: "Failed to delete assessment" });
  }
};

// ============================================================
// RESET USER PASSWORD — POST /api/admin/users/:id/reset-password
// Admin sets a new password for a user (e.g. support requests).
// ============================================================
const resetUserPassword = async (req, res) => {
  try {
    const { id } = req.params;
    const { newPassword } = req.body;

    if (!newPassword || newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        message: "New password must be at least 6 characters",
      });
    }
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res
        .status(400)
        .json({ success: false, message: "Invalid user id" });
    }

    const user = await User.findById(id);
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    user.password = await bcrypt.hash(newPassword, 10);
    user.resetOtp = null;
    user.resetOtpExpires = null;
    await user.save();

    console.log(`[Admin] Password reset for ${user.email}`);
    return res.json({ success: true, message: "Password updated" });
  } catch (error) {
    console.error("[Admin] Reset password error:", error.message);
    return res
      .status(500)
      .json({ success: false, message: "Failed to reset password" });
  }
};

module.exports = {
  getStats,
  listUsers,
  getUserDetail,
  deleteUser,
  listAssessments,
  deleteAssessment,
  resetUserPassword,
};
