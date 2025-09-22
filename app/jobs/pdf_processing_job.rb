class PdfProcessingJob < ApplicationJob
  queue_as :default

  def perform(upload_id)
    upload = Upload.find(upload_id)

    # Extract text from PDF
    file_path = ActiveStorage::Blob.service.path_for(upload.pdf_file.key)
    pdf_text = PdfTextExtractor.extract_text(file_path)

    # Generate questions
    service = GeminiQuestionService.new(pdf_text, upload)
    questions_data = service.generate_questions

    # Create questions and options
    create_questions(upload, questions_data)
  end

  private

  def create_questions(upload, questions_data)
    # Create objective questions
    questions_data["objective_questions"].each do |q_data|
      question = upload.questions.create!(
        content: q_data["question"],
        question_type: :objective
      )

      q_data["options"].each do |o_data|
        question.options.create!(
          content: o_data["text"],
          correct: o_data["correct"]
        )
      end
    end

    # Create theory questions
    questions_data["theory_questions"].each do |q_data|
      upload.questions.create!(
        content: q_data["question"],
        question_type: :theory
      )
    end
  end
end
