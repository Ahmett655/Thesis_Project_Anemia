// WaafiPay (Hormuud) merchant credentials.
//
// SECURITY: these belong on the server only — never ship them to the
// Flutter client. Override via environment variables in production.
module.exports = {
  endpoint: process.env.WAAFI_ENDPOINT || "https://api.waafipay.net/asm",
  merchantUid: process.env.WAAFI_MERCHANT_UID || "M0910291",
  apiUserId: process.env.WAAFI_API_USER_ID || "1000416",
  apiKey: process.env.WAAFI_API_KEY || "API-675418888AHX",
  // Default currency for charges.
  currency: process.env.WAAFI_CURRENCY || "USD",
};
