const axios = require("axios");
const waafi = require("../config/waafipay");

// ============================================================
// CHARGE — POST /api/payment/charge
// Body: { accountNo, amount?, description? }
// Calls WaafiPay API_PURCHASE with the merchant credentials (kept
// server-side) and returns whether the payment was approved.
// ============================================================
const charge = async (req, res) => {
  try {
    let { accountNo, amount, description } = req.body;

    if (!accountNo || `${accountNo}`.trim().length < 7) {
      return res.status(400).json({
        success: false,
        message: "A valid mobile money number is required",
      });
    }

    // Normalise the phone number to WaafiPay format (252XXXXXXXXX).
    accountNo = `${accountNo}`.replace(/[^0-9]/g, "");
    if (accountNo.startsWith("0")) accountNo = accountNo.slice(1);
    if (!accountNo.startsWith("252")) accountNo = `252${accountNo}`;

    const payAmount = Number(amount) > 0 ? Number(amount) : 0.1;
    const referenceId = `ANEMIA-${Date.now()}`;
    const invoiceId = `INV-${Math.floor(Math.random() * 1e9)}`;

    const payload = {
      schemaVersion: "1.0",
      requestId: `${Date.now()}`,
      timestamp: new Date().toISOString(),
      channelName: "WEB",
      serviceName: "API_PURCHASE",
      serviceParams: {
        merchantUid: waafi.merchantUid,
        apiUserId: waafi.apiUserId,
        apiKey: waafi.apiKey,
        paymentMethod: "mwallet_account",
        payerInfo: { accountNo },
        transactionInfo: {
          referenceId,
          invoiceId,
          amount: payAmount,
          currency: waafi.currency,
          description: description || "Anemia assessment result",
        },
      },
    };

    console.log(`[Payment] Charging ${accountNo} ${payAmount} ${waafi.currency}`);

    const { data } = await axios.post(waafi.endpoint, payload, {
      headers: { "Content-Type": "application/json" },
      timeout: 60000,
    });

    // WaafiPay: responseCode "2001" + state APPROVED == success.
    const approved =
      data &&
      (data.responseCode === "2001" ||
        (data.params && data.params.state === "APPROVED"));

    if (approved) {
      console.log(`[Payment] APPROVED ref=${referenceId}`);
      return res.json({
        success: true,
        message: "Payment approved",
        referenceId,
        transactionId: data.params ? data.params.transactionId : null,
      });
    }

    console.warn(
      `[Payment] DECLINED: ${data && data.responseMsg ? data.responseMsg : "unknown"}`
    );
    return res.status(402).json({
      success: false,
      message:
        (data && (data.responseMsg || data.errorMessage)) ||
        "Payment was not approved",
      responseCode: data ? data.responseCode : null,
    });
  } catch (error) {
    const apiMsg =
      error.response && error.response.data
        ? error.response.data.responseMsg || JSON.stringify(error.response.data)
        : error.message;
    console.error("[Payment] error:", apiMsg);
    return res.status(500).json({
      success: false,
      message: "Payment request failed. Please try again.",
      error: apiMsg,
    });
  }
};

module.exports = { charge };
