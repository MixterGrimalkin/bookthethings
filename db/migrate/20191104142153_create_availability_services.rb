class CreateAvailabilityServices < ActiveRecord::Migration[5.1]
  def change
    create_table :availability_services do |t|
      t.integer :availability_id
      t.integer :service_id

      t.timestamps
    end
  end
end
