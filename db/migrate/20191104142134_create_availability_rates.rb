class CreateAvailabilityRates < ActiveRecord::Migration[5.1]
  def change
    create_table :availability_rates do |t|
      t.integer :availability_id
      t.integer :rate_id

      t.timestamps
    end
  end
end
