const axios = require("axios");
const Result = require("../models/Result");

const predictAnemia = async (req, res) => {
  try {
    const { category, ...userData } = req.body;

    const response = await axios.post(
      "http://127.0.0.1:5000/predict",
      req.body,
    );

    // Save with optional userId (null for guests)
    const savedResult = await Result.create({
      userId: req.userId || null,
      category: category || "women",
      answers: userData,
      prediction_number: response.data.prediction_number,
      prediction_label: response.data.prediction_label,
      confidence: response.data.confidence,
      method: response.data.method,
      hemoglobin_value: response.data.hemoglobin_value,
    });

    res.status(200).json({
      message: "Prediction successful",
      result: {
        ...savedResult.toObject(),
        confidence: response.data.confidence,
        method: response.data.method,
        hemoglobin_value: response.data.hemoglobin_value,
      },
    });
  } catch (error) {
    res.status(500).json({
      error: "Prediction failed",
      details: error.message,
    });
  }
};

/**
 * GET /api/assessments/history
 * Returns the logged-in user's assessment history, most recent first.
 */
const getHistory = async (req, res) => {
  try {
    const userId = req.userId;
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "Authentication required",
      });
    }

    const results = await Result.find({ userId })
      .sort({ createdAt: -1 })
      .limit(50);

    res.status(200).json({
      success: true,
      count: results.length,
      assessments: results.map((r) => ({
        id: r._id,
        category: r.category,
        prediction_number: r.prediction_number,
        prediction_label: r.prediction_label,
        confidence: r.confidence,
        method: r.method,
        hemoglobin_value: r.hemoglobin_value,
        createdAt: r.createdAt,
      })),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to fetch history",
      error: error.message,
    });
  }
};

module.exports = { predictAnemia, getHistory };
