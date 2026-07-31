const Booking = require("../models/Booking");

// Generate a human-friendly, reasonably-unique reference number, e.g.
// ANEM-20260731-4F9K2.
function makeReference() {
  const d = new Date();
  const ymd =
    d.getFullYear().toString() +
    String(d.getMonth() + 1).padStart(2, "0") +
    String(d.getDate()).padStart(2, "0");
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // no confusing 0/O/1/I
  let suffix = "";
  for (let i = 0; i < 5; i++) {
    suffix += chars[Math.floor(Math.random() * chars.length)];
  }
  return `ANEM-${ymd}-${suffix}`;
}

// POST /api/booking — create a booking (guests allowed via optionalAuth)
exports.createBooking = async (req, res) => {
  try {
    const {
      patientName,
      patientPhone,
      hospitalName,
      hospitalAddress,
      hospitalPhone,
      hospitalLat,
      hospitalLon,
      appointmentDate,
      appointmentTime,
      category,
      riskLabel,
      riskNumber,
      confidence,
      hemoglobin,
    } = req.body;

    if (!patientName || !hospitalName || !appointmentDate || !appointmentTime) {
      return res.status(400).json({
        success: false,
        message:
          "patientName, hospitalName, appointmentDate and appointmentTime are required",
      });
    }

    // Generate a unique reference (retry a few times on the rare collision)
    let referenceNumber;
    for (let attempt = 0; attempt < 5; attempt++) {
      referenceNumber = makeReference();
      const exists = await Booking.findOne({ referenceNumber }).lean();
      if (!exists) break;
    }

    const booking = await Booking.create({
      referenceNumber,
      userId: req.userId || null,
      patientName,
      patientPhone,
      hospitalName,
      hospitalAddress,
      hospitalPhone,
      hospitalLat,
      hospitalLon,
      appointmentDate,
      appointmentTime,
      category,
      riskLabel,
      riskNumber,
      confidence,
      hemoglobin,
    });

    return res.status(201).json({
      success: true,
      message: "Booking confirmed",
      booking,
    });
  } catch (e) {
    console.error("[Booking] create failed:", e.message);
    return res
      .status(500)
      .json({ success: false, message: "Failed to create booking" });
  }
};

// GET /api/booking/history — the logged-in user's bookings (newest first)
exports.getBookings = async (req, res) => {
  try {
    const bookings = await Booking.find({ userId: req.userId })
      .sort({ createdAt: -1 })
      .lean();
    return res.json({ success: true, bookings });
  } catch (e) {
    console.error("[Booking] history failed:", e.message);
    return res
      .status(500)
      .json({ success: false, message: "Failed to fetch bookings" });
  }
};
