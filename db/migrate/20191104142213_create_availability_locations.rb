class CreateAvailabilityLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :availability_locations do |t|
      t.integer :availability_id
      t.integer :location_id

      t.timestamps
    end
  end
end
