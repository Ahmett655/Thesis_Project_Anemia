const User = require("../models/User");
const Result = require("../models/Result");
const Booking = require("../models/Booking");

// ============================================================
// ACTIVITY REPORTS — GET /api/reports?period=daily|weekly|monthly
// Aggregates everything that happened in the system over the
// selected period so the admin can review and export it as PDF.
// ============================================================

/** Start date for the requested period (end is always "now"). */
function periodRange(period) {
  const now = new Date();
  const start = new Date(now);

  switch (period) {
    case "daily":
      start.setHours(0, 0, 0, 0); // today from midnight
      break;
    case "monthly":
      start.setDate(start.getDate() - 29); // last 30 days
      start.setHours(0, 0, 0, 0);
      break;
    case "weekly":
    default:
      start.setDate(start.getDate() - 6); // last 7 days
      start.setHours(0, 0, 0, 0);
      break;
  }
  return { start, end: now };
}

function labelFor(period) {
  if (period === "daily") return "Daily Report";
  if (period === "monthly") return "Monthly Report";
  return "Weekly Report";
}

/** Fills missing days with zero so the trend line has no gaps. */
function buildTrend(rows, start, end) {
  const map = {};
  rows.forEach((r) => (map[r._id] = r.count));

  const trend = [];
  const cursor = new Date(start);
  while (cursor <= end) {
    const key = cursor.toISOString().slice(0, 10); // YYYY-MM-DD
    trend.push({ date: key, count: map[key] || 0 });
    cursor.setDate(cursor.getDate() + 1);
  }
  return trend;
}

const getReport = async (req, res) => {
  try {
    const period = (req.query.period || "weekly").toLowerCase();
    if (!["daily", "weekly", "monthly"].includes(period)) {
      return res.status(400).json({
        success: false,
        message: "period must be daily, weekly or monthly",
      });
    }

    const { start, end } = periodRange(period);
    const inRange = { createdAt: { $gte: start, $lte: end } };

    const [
      totalAssessments,
      guestAssessments,
      newUsers,
      totalBookings,
      byRisk,
      byCategory,
      byMethod,
      hbProvided,
      confAgg,
      trendRows,
      recent,
      topBookings,
    ] = await Promise.all([
      Result.countDocuments(inRange),
      Result.countDocuments({ ...inRange, userId: null }),
      User.countDocuments({ ...inRange, role: { $ne: "admin" } }),
      Booking.countDocuments(inRange),

      Result.aggregate([
        { $match: inRange },
        { $group: { _id: "$prediction_number", count: { $sum: 1 } } },
      ]),
      Result.aggregate([
        { $match: inRange },
        { $group: { _id: "$category", count: { $sum: 1 } } },
      ]),
      Result.aggregate([
        { $match: inRange },
        { $group: { _id: "$method", count: { $sum: 1 } } },
      ]),

      Result.countDocuments({ ...inRange, hemoglobin_value: { $gt: 0 } }),

      Result.aggregate([
        { $match: inRange },
        { $group: { _id: null, avg: { $avg: "$confidence" } } },
      ]),

      // assessments per day (for the trend chart)
      Result.aggregate([
        { $match: inRange },
        {
          $group: {
            _id: {
              $dateToString: { format: "%Y-%m-%d", date: "$createdAt" },
            },
            count: { $sum: 1 },
          },
        },
        { $sort: { _id: 1 } },
      ]),

      Result.find(inRange)
        .sort({ createdAt: -1 })
        .limit(10)
        .select("category prediction_label confidence method createdAt"),

      Booking.find(inRange)
        .sort({ createdAt: -1 })
        .limit(10)
        .select("referenceNumber patientName hospitalName appointmentDate appointmentTime riskLabel createdAt"),
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

    // Group the free-text method into the two branches of the hybrid layer
    const method = { who: 0, ml: 0, other: 0 };
    byMethod.forEach((m) => {
      const name = (m._id || "").toString();
      if (name.includes("WHO")) method.who += m.count;
      else if (name.includes("Machine")) method.ml += m.count;
      else method.other += m.count;
    });

    return res.json({
      success: true,
      report: {
        period,
        label: labelFor(period),
        startDate: start.toISOString(),
        endDate: end.toISOString(),
        generatedAt: new Date().toISOString(),

        summary: {
          totalAssessments,
          guestAssessments,
          registeredAssessments: totalAssessments - guestAssessments,
          newUsers,
          totalBookings,
          hemoglobinProvided: hbProvided,
          averageConfidence: confAgg.length ? confAgg[0].avg : 0,
        },

        risk,
        category,
        method,
        trend: buildTrend(trendRows, start, end),
        recentAssessments: recent,
        recentBookings: topBookings,
      },
    });
  } catch (error) {
    console.error("[Report] error:", error.message);
    return res
      .status(500)
      .json({ success: false, message: "Failed to build report" });
  }
};

module.exports = { getReport };
