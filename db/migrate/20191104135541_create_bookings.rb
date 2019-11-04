class CreateBookings < ActiveRecord::Migration[5.1]
  def change
    create_table :bookings do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.integer :customer_id
      t.integer :provider_id
      t.integer :location_id
      t.integer :service_id
      t.integer :cost
      t.boolean :confirmed

      t.timestamps
    end
  end
end
