class CreateUploads < ActiveRecord::Migration[8.0]
  def change
    create_table :uploads do |t|
      t.string :name
      t.string :cloudinary_url

      t.timestamps
    end
  end
end
