class CreateProviderLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :provider_locations do |t|
      t.integer :provider_id
      t.integer :location_id

      t.timestamps
    end
  end
end
