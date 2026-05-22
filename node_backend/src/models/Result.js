const mongoose = require("mongoose");

const resultSchema = new mongoose.Schema(
  {
    // userId is optional — guests have no userId
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: false,
      index: true,
    },
    category: {
      type: String,
      enum: ["men", "women", "children"],
      required: true,
    },
    answers: {
      type: Object,
      required: true,
    },
    prediction_number: {
      type: Number,
      required: true,
    },
    prediction_label: {
      type: String,
      required: true,
    },
    confidence: {
      type: Number,
      required: false,
    },
    method: {
      type: String,
      required: false,
    },
    hemoglobin_value: {
      type: Number,
      required: false,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Result", resultSchema);