class CreateUploads < ActiveRecord::Migration[8.0]
  def change
    create_table :uploads do |t|
      t.string :name, null: false
      t.string :cloudinary_url
      t.string :public_id

      t.timestamps
    end
  end
end
