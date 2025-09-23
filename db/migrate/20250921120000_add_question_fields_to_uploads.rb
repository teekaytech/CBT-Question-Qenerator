class AddQuestionFieldsToUploads < ActiveRecord::Migration[6.1]
  def change
    add_column :uploads, :number_of_objective_questions, :integer, default: 0, null: false
    add_column :uploads, :number_of_theory_questions, :integer, default: 0, null: false
    add_column :uploads, :show_answers, :boolean, default: false, null: false
  end
end
