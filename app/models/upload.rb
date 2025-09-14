class Upload < ApplicationRecord
  has_many :questions, dependent: :destroy
  validates :name, presence: true

  # For Active Storage file uploads
  has_one_attached :pdf_file
end
