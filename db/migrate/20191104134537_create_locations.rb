class CreateLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :locations do |t|
      t.text :street_address
      t.string :postcode

      t.timestamps
    end
  end
end
