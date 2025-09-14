class Question < ApplicationRecord
  belongs_to :upload
  has_many :options, dependent: :destroy

  enum question_type: { objective: 0, theory: 1 }

  accepts_nested_attributes_for :options
end
