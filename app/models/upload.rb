class Upload < ApplicationRecord
  has_many :questions, dependent: :destroy
  validates :name, presence: true

  validate :at_least_one_question_type

  # Custom validation
  def at_least_one_question_type
    if number_of_objective_questions.to_i == 0 && number_of_theory_questions.to_i == 0
      errors.add(:base, "At least one of objective or theory questions must be given.")
    end
  end

  # For Active Storage file uploads
  has_one_attached :pdf_file

  before_destroy :purge_pdf_file, :delete_cloudinary_file

  private

  def purge_pdf_file
    pdf_file.purge if pdf_file.attached?
  end

  def delete_cloudinary_file
    if public_id.present?
      begin
        Cloudinary::Uploader.destroy(public_id)
      rescue => e
        Rails.logger.error "Failed to delete Cloudinary file: #{e.message}"
      end
    end
  end
end
