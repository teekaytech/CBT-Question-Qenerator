require 'rails_helper'

describe "uploads/index.html.erb", type: :view do
  it "renders the uploads table and links" do
    assign(:uploads, [ Upload.create!(name: 'Test', number_of_objective_questions: 1, number_of_theory_questions: 1, show_answers: false, created_at: Time.current) ])
    render
    expect(rendered).to match /Uploaded Documents/
    expect(rendered).to match /Test/
    expect(rendered).to match /View Questions/
    expect(rendered).to match /Regenerate Questions/
    expect(rendered).to match /Edit/
    expect(rendered).to match /Delete/
  end
end
