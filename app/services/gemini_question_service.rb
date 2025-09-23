class GeminiQuestionService
  def initialize(pdf_text, upload)
    @pdf_text = pdf_text.truncate(30000) # Gemini 1.5 allows up to 1M tokens!
    @upload = upload
  end

  def generate_questions
    return generate_fallback_questions unless gemini_configured?

    begin
      attempt_generate_questions
    rescue => e
      Rails.logger.error "Gemini API Error: #{e.message}"
      generate_fallback_questions
    end
  end

  private

  def gemini_configured?
    ENV["GEMINI_API_KEY"].present? && ENV["GEMINI_API_KEY"] != "your_gemini_api_key"
  end

  def attempt_generate_questions
    # Initialize the Gemini client
    client = GeminiClient
    prompt = build_prompt

    Rails.logger.info "Sending request to Gemini API (non-streaming)..."

    # Generate content using Gemini 1.5 Flash
    # Use generate_content instead of stream_generate_content
    response = client.generate_content({ contents: { role: "user", parts: { text: prompt } } })

    Rails.logger.info "Gemini response type: #{response.class}"
    Rails.logger.info "Gemini response: #{response.inspect}"

    parse_response(response)
  end

  def build_prompt
    <<~PROMPT
      ANALYZE THIS DOCUMENT AND GENERATE EDUCATIONAL QUESTIONS. MAKE SURE ALL QUESTIONS ARE CORRECTLY CONSTRUCTED AND MEANINGFUL, BASED STRICTLY ON THE DOCUMENT CONTENT:

      DOCUMENT CONTENT:
      #{@pdf_text}

      TASK: Generate exactly #{@upload.number_of_objective_questions} high-quality multiple-choice questions (with 4 options each, one correct answer)
      and exactly #{@upload.number_of_theory_questions} theory questions based strictly on the document content. Ensure that no question is repeated.

      REQUIREMENTS:
      1. Multiple-choice questions must test comprehension of key concepts
      2. Each question must have exactly 4 options (A, B, C, D)
      3. Only one correct answer per multiple-choice question
      4. Options should be plausible but only one correct
      5. Theory questions should require explanation/analysis of document content
      6. All questions must be directly based on information in the document

      FORMAT STRICTLY AS VALID JSON ONLY:
      {
        "objective_questions": [
          {
            "question": "Clear question text based on document",
            "options": [
              {"text": "Correct answer", "correct": true},
              {"text": "Plausible but incorrect", "correct": false},
              {"text": "Another incorrect option", "correct": false},
              {"text": "Clearly wrong option", "correct": false}
            ]
          }
        ],
        "theory_questions": [
          {"question": "Thought-provoking theory question 1"},
          {"question": "Analytical theory question 2"}
        ]
      }

      Return ONLY the JSON object, no additional text, explanations, or markdown formatting.
    PROMPT
  end

  def parse_response(response)
    response_text = extract_text_from_response(response)

    Rails.logger.info "Extracted response text: #{response_text}"

    return generate_fallback_questions if response_text.nil? || response_text.empty?

    # Clean the response to extract JSON
    cleaned_content = clean_response(response_text)

    Rails.logger.info "Cleaned content: #{cleaned_content}"

    JSON.parse(cleaned_content)
  rescue JSON::ParserError => e
    Rails.logger.error "Failed to parse Gemini response: #{e.message}\nResponse: #{response_text}"
    generate_fallback_questions
  end

  def extract_text_from_response(response)
    case response
    when String
      response
    when Hash
      # Try different possible response formats from Gemini API
      response.dig("candidates", 0, "content", "parts", 0, "text") ||
      response.dig("text") ||
      response.dig(:text) ||
      response.to_json
    else
      response.to_s
    end
  end

  def clean_response(text)
    # Remove markdown code blocks
    cleaned = text.gsub(/```json\s*|\s*```/, "")

    # Extract JSON from the response (look for the first { and last })
    json_match = cleaned.match(/\{[\s\S]*\}/)

    if json_match
      json_match[0]
    else
      # If no JSON found, try to construct a simple JSON structure
      generate_basic_json_from_text(cleaned)
    end
  end

  def generate_basic_json_from_text(text)
    # Fallback: create simple questions based on text presence
    {
      "objective_questions" => [
        {
          "question" => "What is the main topic of this document?",
          "options" => [
            { "text" => "The primary subject matter", "correct" => true },
            { "text" => "An unrelated topic", "correct" => false },
            { "text" => "Background information", "correct" => false },
            { "text" => "Technical details", "correct" => false }
          ]
        }
      ],
      "theory_questions" => [
        { "question" => "Explain the key concepts in this document" }
      ]
    }.to_json
  end

  def generate_fallback_questions
    {
      "objective_questions" => [
        {
          "question" => "Based on the document content, what appears to be the main topic or subject?",
          "options" => [
            { "text" => "The primary theme discussed throughout the text", "correct" => true },
            { "text" => "A minor detail mentioned in passing", "correct" => false },
            { "text" => "Background information only", "correct" => false },
            { "text" => "An unrelated concept not in the document", "correct" => false }
          ]
        }
      ],
      "theory_questions" => []
    }
  end
end
