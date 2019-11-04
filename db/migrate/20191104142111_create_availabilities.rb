class CreateAvailabilities < ActiveRecord::Migration[5.1]
  def change
    create_table :availabilities do |t|
      t.integer :provider_id
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :repeat_weekly_until
      t.boolean :all_services
      t.boolean :all_locations
      t.boolean :remote_locations
      t.integer :base_location_id

      t.timestamps
    end
  end
end
