class CreateProviders < ActiveRecord::Migration[5.1]
  def change
    create_table :providers do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.text :description
      t.string :web_link
      t.string :photo_url
      t.integer :company_id

      t.timestamps
    end
  end
end
