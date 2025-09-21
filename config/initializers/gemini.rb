
require "gemini-ai"

GeminiClient = Gemini.new(
  credentials: {
    service: "generative-language-api",
    api_key: ENV["GEMINI_API_KEY"]
  },
  options: { model: "gemini-1.5-flash", server_sent_events: true }
)
