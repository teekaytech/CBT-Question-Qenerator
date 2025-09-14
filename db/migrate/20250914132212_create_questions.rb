class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.references :upload, null: false, foreign_key: true
      t.integer :question_type
      t.text :content

      t.timestamps
    end
  end
end
