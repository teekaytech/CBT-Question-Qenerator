require 'rails_helper'

describe Upload, type: :model do
  it 'is valid with valid attributes' do
    upload = Upload.new(name: 'Test', number_of_objective_questions: 1, number_of_theory_questions: 0)
    expect(upload).to be_valid
  end

  it 'is invalid without a name' do
    upload = Upload.new(name: nil, number_of_objective_questions: 1, number_of_theory_questions: 0)
    expect(upload).not_to be_valid
    expect(upload.errors[:name]).to be_present
  end

  it 'is invalid if both question counts are zero' do
    upload = Upload.new(name: 'Test', number_of_objective_questions: 0, number_of_theory_questions: 0)
    expect(upload).not_to be_valid
    expect(upload.errors[:base]).to include(/At least one of objective or theory questions/)
  end

  it 'can have many questions' do
    assoc = described_class.reflect_on_association(:questions)
    expect(assoc.macro).to eq :has_many
  end

  it 'responds to show_answers' do
    upload = Upload.new
    expect(upload).to respond_to(:show_answers)
  end
end
