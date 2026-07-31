const mongoose = require("mongoose");

// A hospital appointment booking created from an assessment result.
// NOTE: this is a prototype/simulated booking — no real hospital receives it.
// The record is stored so the patient gets a reference number and receipt.
const bookingSchema = new mongoose.Schema(
  {
    referenceNumber: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    // Optional — guests can book without an account
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: false,
      index: true,
    },
    patientName: { type: String, required: true },
    patientPhone: { type: String, required: false },

    hospitalName: { type: String, required: true },
    hospitalAddress: { type: String, required: false },
    hospitalPhone: { type: String, required: false },
    hospitalLat: { type: Number, required: false },
    hospitalLon: { type: Number, required: false },

    appointmentDate: { type: String, required: true }, // e.g. "2026-08-05"
    appointmentTime: { type: String, required: true }, // e.g. "09:30"

    // Snapshot of the assessment result at booking time
    category: { type: String, required: false },
    riskLabel: { type: String, required: false },
    riskNumber: { type: Number, required: false },
    confidence: { type: Number, required: false },
    hemoglobin: { type: Number, required: false },

    status: { type: String, default: "confirmed" },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Booking", bookingSchema);
