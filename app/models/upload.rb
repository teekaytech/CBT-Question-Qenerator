class Upload < ApplicationRecord
  has_many :questions, dependent: :destroy
  validates :name, presence: true

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
