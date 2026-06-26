const Anthropic = require("@anthropic-ai/sdk");

// Reads ANTHROPIC_API_KEY from the environment. Never hard-code the key.
const client = new Anthropic();

// Model: per Anthropic guidance, default to the latest Opus. To lower cost for
// this simple Q&A chatbot you can switch to "claude-haiku-4-5".
const MODEL = process.env.CHAT_MODEL || "claude-opus-4-8";

// Static system prompt — kept byte-stable so it can be prompt-cached.
// (Prompt caching only kicks in once the cached prefix reaches the model's
// minimum — ~4096 tokens for Opus, ~2048 for Sonnet/Haiku. A short prompt like
// this may not reach it; the cache_control marker is harmless either way.)
const SYSTEM_PROMPT = `You are "Dhiig-Caawiye", a friendly health assistant for an Anemia Risk Assessment app used in low-resource settings (mainly Somalia).

Your job: answer users' questions about anemia (yaraanta dhiigga) clearly and simply.

RULES:
- Reply in the SAME language the user writes in. If they write Somali, answer in Somali; if English, answer in English. If mixed, mirror them.
- Keep answers short, practical, and easy to understand. Avoid medical jargon; when you must use a term, explain it briefly.
- Cover: what anemia is, symptoms (daal, dawakhaad, cabowga, wadno garaac), causes (iron deficiency, malaria, frequent childbirth, poor nutrition), iron-rich foods (beerka, hilibka cas, digirta, khudaarta cagaarka, ukunta), prevention, and when to see a doctor.
- ALWAYS include a brief safety note when giving health guidance: this is general information, not a diagnosis, and they should see a health worker for testing/treatment — especially for severe symptoms.
- If asked something unrelated to health/anemia, gently redirect to anemia topics.
- Never invent specific drug doses or claim to diagnose. Encourage a real blood test (hemoglobin) for certainty.
- Respond directly with the answer. Do not include exploratory reasoning, drafts, or meta-commentary about your process.`;

// ============================================================
// CHAT — POST /api/chat
// Body: { messages: [{ role: "user"|"assistant", content: "..." }, ...] }
//   OR: { message: "..." } for a single-turn question.
// Returns: { success: true, reply: "..." }
// ============================================================
const chat = async (req, res) => {
  try {
    let { messages, message } = req.body;

    // Accept either a full messages array or a single message string.
    if (!Array.isArray(messages) || messages.length === 0) {
      if (typeof message === "string" && message.trim()) {
        messages = [{ role: "user", content: message.trim() }];
      } else {
        return res.status(400).json({
          success: false,
          message: "Provide `messages` (array) or `message` (string).",
        });
      }
    }

    // Sanitize: only user/assistant roles, string content, cap history length.
    const clean = messages
      .filter(
        (m) =>
          m &&
          (m.role === "user" || m.role === "assistant") &&
          typeof m.content === "string" &&
          m.content.trim()
      )
      .slice(-20)
      .map((m) => ({ role: m.role, content: m.content.trim() }));

    if (clean.length === 0 || clean[0].role !== "user") {
      return res.status(400).json({
        success: false,
        message: "Conversation must start with a user message.",
      });
    }

    const response = await client.messages.create({
      model: MODEL,
      max_tokens: 1024,
      // System prompt as a cacheable block (stable prefix).
      system: [
        {
          type: "text",
          text: SYSTEM_PROMPT,
          cache_control: { type: "ephemeral" },
        },
      ],
      messages: clean,
    });

    const reply = response.content
      .filter((b) => b.type === "text")
      .map((b) => b.text)
      .join("\n")
      .trim();

    return res.json({
      success: true,
      reply: reply || "Waan ka xumahay, ma haynin jawaab. Isku day mar kale.",
    });
  } catch (error) {
    console.error("[Chat] error:", error.message);
    // Surface a friendlier message when the key is missing/invalid.
    const isAuth =
      error.status === 401 || /api[_ ]?key/i.test(error.message || "");
    return res.status(500).json({
      success: false,
      message: isAuth
        ? "AI service is not configured (missing ANTHROPIC_API_KEY)."
        : "AI service error. Please try again.",
    });
  }
};

module.exports = { chat };
